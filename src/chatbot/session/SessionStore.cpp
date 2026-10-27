// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "SessionStore.h"

#include <SQLiteCpp/SQLiteCpp.h>
#include <sqlite3.h>

#include <exception>
#include <utility>

namespace mod::chatbot {

namespace {

// Bump together with a migration entry below. A database written by a newer
// build must be rejected instead of silently written with an older schema.
constexpr int kSchemaVersion = 1;

Error sqliteError(ErrorCode code, const SQLite::Exception& e) {
    return Error{code, e.what()};
}

int readUserVersion(SQLite::Database& db) {
    SQLite::Statement query(db, "PRAGMA user_version");
    if (!query.executeStep()) return 0;
    return query.getColumn(0).getInt();
}

} // namespace

std::string_view eventKindName(EventKind kind) {
    switch (kind) {
        case EventKind::UserMessage: return "user-message";
        case EventKind::AssistantText: return "assistant-text";
        case EventKind::AssistantReasoning: return "assistant-reasoning";
        case EventKind::ToolCall: return "tool-call";
        case EventKind::ToolResult: return "tool-result";
        case EventKind::RequestHeader: return "request-header";
        case EventKind::Unknown: return "unknown";
    }
    return "unknown";
}

std::optional<EventKind> eventKindFromName(std::string_view name) {
    if (name == "user-message") return EventKind::UserMessage;
    if (name == "assistant-text") return EventKind::AssistantText;
    if (name == "assistant-reasoning") return EventKind::AssistantReasoning;
    if (name == "tool-call") return EventKind::ToolCall;
    if (name == "tool-result") return EventKind::ToolResult;
    if (name == "request-header") return EventKind::RequestHeader;
    return std::nullopt;
}

SessionStore::SessionStore(std::unique_ptr<SQLite::Database> db) : m_db(std::move(db)) {}

SessionStore::~SessionStore() = default;

Result<std::unique_ptr<SessionStore>> SessionStore::open(const std::string& path) {
    if (path.empty()) {
        return fail(ErrorCode::InvalidArgument, "database path is empty");
    }

    try {
        auto db = std::make_unique<SQLite::Database>(
            path,
            SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
            5000);
        auto store = std::make_unique<SessionStore>(std::move(db));
        auto schema = store->initSchema();
        if (!schema) {
            return std::unexpected(schema.error());
        }
        return store;
    } catch (const SQLite::Exception& e) {
        return std::unexpected(sqliteError(ErrorCode::DatabaseOpen, e));
    } catch (const std::exception& e) {
        return fail(ErrorCode::DatabaseOpen, e.what());
    }
}

Result<void> SessionStore::initSchema() {
    try {
        // WAL keeps readers and the single writer independent; the device has very
        // little RAM, so cap the page cache and WAL instead of using defaults.
        m_db->exec("PRAGMA journal_mode = WAL;");
        m_db->exec("PRAGMA application_id = 0x504D5345;");

        // Downgrade guard: a newer build may have added columns whose absence we
        // would not notice until a write. Refuse to open it instead.
        const int existingVersion = readUserVersion(*m_db);
        if (existingVersion > kSchemaVersion) {
            return fail(
                ErrorCode::Schema,
                "database schema v" + std::to_string(existingVersion) + " is newer than this build (v"
                    + std::to_string(kSchemaVersion) + ")");
        }
        m_db->exec("PRAGMA user_version = 1;");
        m_db->exec("PRAGMA cache_size = -2000;");
        m_db->exec("PRAGMA mmap_size = 0;");
        m_db->exec("PRAGMA journal_size_limit = 4194304;");
        m_db->exec("PRAGMA foreign_keys = ON;");

        // P1a stores events.data as JSON text. Switch to BLOB + zstd in P1b;
        // the schema is deliberately STRICT so that change cannot be silent.
        m_db->exec(R"SQL(
CREATE TABLE IF NOT EXISTS sessions (
  id                  TEXT PRIMARY KEY,
  parent_id           TEXT,
  title               TEXT    NOT NULL DEFAULT '',
  model               TEXT,
  created_at          INTEGER NOT NULL,
  updated_at          INTEGER NOT NULL,
  compacted_at        INTEGER,
  archived_at         INTEGER,
  last_seq            INTEGER NOT NULL DEFAULT -1,
  message_count       INTEGER NOT NULL DEFAULT 0,
  tokens_in           INTEGER NOT NULL DEFAULT 0,
  tokens_out          INTEGER NOT NULL DEFAULT 0,
  tokens_reasoning    INTEGER NOT NULL DEFAULT 0,
  tokens_cache_read   INTEGER NOT NULL DEFAULT 0,
  tokens_cache_write  INTEGER NOT NULL DEFAULT 0,
  cost                REAL    NOT NULL DEFAULT 0
) STRICT;

CREATE TABLE IF NOT EXISTS events (
  session_id  TEXT NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  seq         INTEGER NOT NULL,
  turn_id     TEXT NOT NULL,
  kind        TEXT NOT NULL,
  time        INTEGER NOT NULL,
  data        TEXT NOT NULL,
  truncated   INTEGER NOT NULL DEFAULT 0,
  orig_bytes  INTEGER,
  PRIMARY KEY (session_id, seq)
) STRICT;

CREATE INDEX IF NOT EXISTS idx_events_turn ON events(session_id, turn_id, seq);
CREATE INDEX IF NOT EXISTS idx_events_kind ON events(session_id, kind, seq);

CREATE TABLE IF NOT EXISTS event_runs (
  session_id TEXT NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  first_seq  INTEGER NOT NULL,
  count      INTEGER NOT NULL,
  bytes      BLOB NOT NULL,
  PRIMARY KEY (session_id, first_seq)
) STRICT;

CREATE TABLE IF NOT EXISTS message_index (
  session_id        TEXT NOT NULL,
  seq               INTEGER NOT NULL,
  turn_id           TEXT NOT NULL,
  role              TEXT NOT NULL,
  preview           TEXT NOT NULL DEFAULT '',
  byte_len          INTEGER NOT NULL DEFAULT 0,
  tokens_in         INTEGER,
  tokens_out        INTEGER,
  reasoning_tokens  INTEGER,
  PRIMARY KEY (session_id, seq)
) STRICT;

CREATE TABLE IF NOT EXISTS migration (
  id           TEXT PRIMARY KEY,
  completed_at INTEGER NOT NULL
) STRICT;

CREATE TABLE IF NOT EXISTS app_state (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL
) STRICT;
)SQL");

        SQLite::Statement migration(*m_db, "INSERT OR IGNORE INTO migration(id, completed_at) VALUES(?, ?)");
        migration.bind(1, "schema-v1");
        migration.bind(2, nowMillis());
        migration.exec();

        return {};
    } catch (const SQLite::Exception& e) {
        return std::unexpected(sqliteError(ErrorCode::Schema, e));
    } catch (const std::exception& e) {
        return fail(ErrorCode::Schema, e.what());
    }
}

SessionMeta SessionStore::readMeta(const SQLite::Statement& query) {
    SessionMeta meta;
    meta.id = query.getColumn(0).getString();
    if (!query.getColumn(1).isNull()) {
        meta.parentId = query.getColumn(1).getString();
    }
    meta.title = query.getColumn(2).getString();
    if (!query.getColumn(3).isNull()) {
        meta.model = query.getColumn(3).getString();
    }
    meta.createdAt = query.getColumn(4).getInt64();
    meta.updatedAt = query.getColumn(5).getInt64();
    if (!query.getColumn(6).isNull()) {
        meta.compactedAt = query.getColumn(6).getInt64();
    }
    if (!query.getColumn(7).isNull()) {
        meta.archivedAt = query.getColumn(7).getInt64();
    }
    meta.lastSeq = query.getColumn(8).getInt64();
    meta.messageCount = query.getColumn(9).getInt64();
    meta.tokensIn = query.getColumn(10).getInt64();
    meta.tokensOut = query.getColumn(11).getInt64();
    meta.tokensReasoning = query.getColumn(12).getInt64();
    meta.tokensCacheRead = query.getColumn(13).getInt64();
    meta.tokensCacheWrite = query.getColumn(14).getInt64();
    meta.cost = query.getColumn(15).getDouble();
    return meta;
}

Result<SessionMeta> SessionStore::createSession(
    std::string id,
    std::string title,
    std::optional<std::string> model,
    std::int64_t nowMs) {
    if (id.empty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }

    try {
        const std::string finalTitle = title.empty() ? "新对话" : std::move(title);
        SQLite::Statement insert(
            *m_db,
            "INSERT INTO sessions(id, parent_id, title, model, created_at, updated_at) "
            "VALUES(?, NULL, ?, ?, ?, ?)");
        insert.bind(1, id);
        insert.bind(2, finalTitle);
        if (model) {
            insert.bind(3, *model);
        } else {
            insert.bind(3);
        }
        insert.bind(4, nowMs);
        insert.bind(5, nowMs);
        insert.exec();
    } catch (const SQLite::Exception& e) {
        return std::unexpected(sqliteError(ErrorCode::DatabaseQuery, e));
    } catch (const std::exception& e) {
        return fail(ErrorCode::DatabaseQuery, e.what());
    }

    return getSession(id);
}

Result<void> SessionStore::renameSession(const std::string& id, std::string title, std::int64_t nowMs) {
    if (id.empty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }

    try {
        SQLite::Statement update(*m_db, "UPDATE sessions SET title = ?, updated_at = ? WHERE id = ?");
        update.bind(1, title);
        update.bind(2, nowMs);
        update.bind(3, id);
        if (update.exec() == 0) {
            return fail(ErrorCode::NotFound, "session not found: " + id);
        }
        return {};
    } catch (const SQLite::Exception& e) {
        return std::unexpected(sqliteError(ErrorCode::DatabaseQuery, e));
    } catch (const std::exception& e) {
        return fail(ErrorCode::DatabaseQuery, e.what());
    }
}

Result<void> SessionStore::deleteSession(const std::string& id) {
    if (id.empty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }

    try {
        SQLite::Statement remove(*m_db, "DELETE FROM sessions WHERE id = ?");
        remove.bind(1, id);
        if (remove.exec() == 0) {
            return fail(ErrorCode::NotFound, "session not found: " + id);
        }
        return {};
    } catch (const SQLite::Exception& e) {
        return std::unexpected(sqliteError(ErrorCode::DatabaseQuery, e));
    } catch (const std::exception& e) {
        return fail(ErrorCode::DatabaseQuery, e.what());
    }
}

Result<SessionMeta> SessionStore::getSession(const std::string& id) const {
    if (id.empty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }

    try {
        SQLite::Statement query(
            *m_db,
            "SELECT id, parent_id, title, model, created_at, updated_at, compacted_at, archived_at, "
            "last_seq, message_count, tokens_in, tokens_out, tokens_reasoning, tokens_cache_read, "
            "tokens_cache_write, cost FROM sessions WHERE id = ?");
        query.bind(1, id);
        if (!query.executeStep()) {
            return fail(ErrorCode::NotFound, "session not found: " + id);
        }
        return readMeta(query);
    } catch (const SQLite::Exception& e) {
        return std::unexpected(sqliteError(ErrorCode::DatabaseQuery, e));
    } catch (const std::exception& e) {
        return fail(ErrorCode::DatabaseQuery, e.what());
    }
}

Result<std::vector<SessionMeta>> SessionStore::listSessions() const {
    try {
        SQLite::Statement query(
            *m_db,
            "SELECT id, parent_id, title, model, created_at, updated_at, compacted_at, archived_at, "
            "last_seq, message_count, tokens_in, tokens_out, tokens_reasoning, tokens_cache_read, "
            "tokens_cache_write, cost FROM sessions ORDER BY updated_at DESC, id ASC");
        std::vector<SessionMeta> sessions;
        while (query.executeStep()) {
            sessions.push_back(readMeta(query));
        }
        return sessions;
    } catch (const SQLite::Exception& e) {
        return std::unexpected(sqliteError(ErrorCode::DatabaseQuery, e));
    } catch (const std::exception& e) {
        return fail(ErrorCode::DatabaseQuery, e.what());
    }
}

Result<void> SessionStore::upsertSession(const SessionMeta& meta, std::int64_t nowMs) {
    if (meta.id.empty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }

    try {
        const std::int64_t createdAt = meta.createdAt > 0 ? meta.createdAt : nowMs;
        const std::int64_t updatedAt = meta.updatedAt > 0 ? meta.updatedAt : nowMs;
        SQLite::Statement  query(
            *m_db,
            "INSERT INTO sessions(id, title, model, created_at, updated_at) VALUES(?, ?, ?, ?, ?) "
            "ON CONFLICT(id) DO UPDATE SET title = excluded.title, model = excluded.model, "
            "updated_at = excluded.updated_at");
        query.bind(1, meta.id);
        query.bind(2, meta.title);
        if (meta.model) {
            query.bind(3, *meta.model);
        } else {
            query.bind(3);
        }
        query.bind(4, createdAt);
        query.bind(5, updatedAt);
        query.exec();
        return {};
    } catch (const SQLite::Exception& e) {
        return std::unexpected(sqliteError(ErrorCode::DatabaseQuery, e));
    } catch (const std::exception& e) {
        return fail(ErrorCode::DatabaseQuery, e.what());
    }
}

Result<void> SessionStore::addUsage(const std::string& sessionId, const UsageCounters& usage) {
    if (sessionId.empty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }
    if (usage.input < 0 || usage.output < 0 || usage.reasoning < 0 || usage.cacheRead < 0
        || usage.cacheWrite < 0) {
        return fail(ErrorCode::InvalidArgument, "usage counters must be non-negative");
    }
    if (usage.input == 0 && usage.output == 0 && usage.reasoning == 0 && usage.cacheRead == 0
        && usage.cacheWrite == 0) {
        return {};
    }

    try {
        SQLite::Statement update(
            *m_db,
            "UPDATE sessions SET tokens_in = tokens_in + ?, tokens_out = tokens_out + ?, "
            "tokens_reasoning = tokens_reasoning + ?, tokens_cache_read = tokens_cache_read + ?, "
            "tokens_cache_write = tokens_cache_write + ? WHERE id = ?");
        update.bind(1, usage.input);
        update.bind(2, usage.output);
        update.bind(3, usage.reasoning);
        update.bind(4, usage.cacheRead);
        update.bind(5, usage.cacheWrite);
        update.bind(6, sessionId);
        if (update.exec() == 0) {
            return fail(ErrorCode::NotFound, "session not found: " + sessionId);
        }
        return {};
    } catch (const SQLite::Exception& e) {
        return std::unexpected(sqliteError(ErrorCode::DatabaseQuery, e));
    } catch (const std::exception& e) {
        return fail(ErrorCode::DatabaseQuery, e.what());
    }
}

Result<std::vector<SessionEvent>> SessionStore::appendEvents(
    const std::string& sessionId,
    const std::vector<NewEvent>& events,
    std::int64_t nowMs) {
    if (sessionId.empty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }
    if (events.empty()) {
        return std::vector<SessionEvent>{};
    }

    try {
        SQLite::Transaction transaction(*m_db);

        std::int64_t lastSeq = -1;
        {
            SQLite::Statement query(*m_db, "SELECT last_seq FROM sessions WHERE id = ?");
            query.bind(1, sessionId);
            if (!query.executeStep()) {
                return fail(ErrorCode::NotFound, "session not found: " + sessionId);
            }
            lastSeq = query.getColumn(0).getInt64();
        }

        std::vector<SessionEvent> appended;
        appended.reserve(events.size());

        SQLite::Statement insert(
            *m_db,
            "INSERT INTO events(session_id, seq, turn_id, kind, time, data, truncated, orig_bytes) "
            "VALUES(?, ?, ?, ?, ?, ?, ?, ?)");
        std::int64_t messageDelta = 0;

        for (const auto& event : events) {
            SessionEvent row;
            row.seq = ++lastSeq;
            row.turnId = event.turnId;
            row.kind = event.kind;
            row.time = event.time == 0 ? nowMs : event.time;
            row.data = event.data;
            row.truncated = event.truncated;
            row.origBytes = event.origBytes;

            insert.bind(1, sessionId);
            insert.bind(2, row.seq);
            insert.bind(3, row.turnId);
            insert.bind(4, std::string(eventKindName(row.kind)));
            insert.bind(5, row.time);
            insert.bind(6, row.data);
            insert.bind(7, row.truncated ? 1 : 0);
            if (row.origBytes) {
                insert.bind(8, *row.origBytes);
            } else {
                insert.bind(8);
            }
            insert.exec();
            insert.reset();

            if (row.kind != EventKind::RequestHeader) {
                ++messageDelta;
            }
            appended.push_back(std::move(row));
        }

        SQLite::Statement update(
            *m_db,
            "UPDATE sessions SET last_seq = ?, updated_at = ?, message_count = message_count + ? WHERE id = ?");
        update.bind(1, lastSeq);
        update.bind(2, nowMs);
        update.bind(3, messageDelta);
        update.bind(4, sessionId);
        update.exec();

        transaction.commit();
        return appended;
    } catch (const SQLite::Exception& e) {
        return std::unexpected(sqliteError(ErrorCode::DatabaseQuery, e));
    } catch (const std::exception& e) {
        return fail(ErrorCode::DatabaseQuery, e.what());
    }
}

Result<void> SessionStore::deleteEventsFrom(
    const std::string& sessionId,
    std::int64_t minSeq,
    std::int64_t nowMs) {
    if (sessionId.empty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }
    if (minSeq < 0) {
        return fail(ErrorCode::InvalidArgument, "minSeq is negative");
    }

    try {
        SQLite::Transaction transaction(*m_db);

        {
            SQLite::Statement query(*m_db, "SELECT 1 FROM sessions WHERE id = ?");
            query.bind(1, sessionId);
            if (!query.executeStep()) {
                return fail(ErrorCode::NotFound, "session not found: " + sessionId);
            }
        }

        {
            SQLite::Statement remove(*m_db, "DELETE FROM events WHERE session_id = ? AND seq >= ?");
            remove.bind(1, sessionId);
            remove.bind(2, minSeq);
            remove.exec();
        }

        std::int64_t lastSeq      = -1;
        std::int64_t messageCount = 0;
        {
            SQLite::Statement query(
                *m_db,
                "SELECT COALESCE(MAX(seq), -1), "
                "COALESCE(SUM(CASE WHEN kind != 'request-header' THEN 1 ELSE 0 END), 0) "
                "FROM events WHERE session_id = ?");
            query.bind(1, sessionId);
            if (query.executeStep()) {
                lastSeq      = query.getColumn(0).getInt64();
                messageCount = query.getColumn(1).getInt64();
            }
        }

        SQLite::Statement update(
            *m_db,
            "UPDATE sessions SET last_seq = ?, message_count = ?, updated_at = ? WHERE id = ?");
        update.bind(1, lastSeq);
        update.bind(2, messageCount);
        update.bind(3, nowMs);
        update.bind(4, sessionId);
        update.exec();

        transaction.commit();
        return {};
    } catch (const SQLite::Exception& e) {
        return std::unexpected(sqliteError(ErrorCode::DatabaseQuery, e));
    } catch (const std::exception& e) {
        return fail(ErrorCode::DatabaseQuery, e.what());
    }
}

Result<std::optional<std::string>> SessionStore::lastUserTurnId(const std::string& sessionId) const {
    if (sessionId.empty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }

    try {
        SQLite::Statement query(
            *m_db,
            "SELECT turn_id FROM events WHERE session_id = ? AND kind = 'user-message' "
            "ORDER BY seq DESC LIMIT 1");
        query.bind(1, sessionId);
        if (!query.executeStep()) {
            return std::optional<std::string>{};
        }
        return std::optional<std::string>(query.getColumn(0).getString());
    } catch (const SQLite::Exception& e) {
        return std::unexpected(sqliteError(ErrorCode::DatabaseQuery, e));
    } catch (const std::exception& e) {
        return fail(ErrorCode::DatabaseQuery, e.what());
    }
}

Result<std::optional<std::string>> SessionStore::getState(const std::string& key) const {
    try {
        SQLite::Statement query(*m_db, "SELECT value FROM app_state WHERE key = ?");
        query.bind(1, key);
        if (!query.executeStep()) {
            return std::optional<std::string>{};
        }
        return std::optional<std::string>(query.getColumn(0).getString());
    } catch (const SQLite::Exception& e) {
        return std::unexpected(sqliteError(ErrorCode::DatabaseQuery, e));
    } catch (const std::exception& e) {
        return fail(ErrorCode::DatabaseQuery, e.what());
    }
}

Result<void> SessionStore::setState(const std::string& key, std::string value) {
    try {
        SQLite::Statement query(
            *m_db,
            "INSERT INTO app_state(key, value) VALUES(?, ?) "
            "ON CONFLICT(key) DO UPDATE SET value = excluded.value");
        query.bind(1, key);
        query.bind(2, value);
        query.exec();
        return {};
    } catch (const SQLite::Exception& e) {
        return std::unexpected(sqliteError(ErrorCode::DatabaseQuery, e));
    } catch (const std::exception& e) {
        return fail(ErrorCode::DatabaseQuery, e.what());
    }
}

Result<std::vector<SessionEvent>> SessionStore::loadEvents(const std::string& sessionId) const {
    if (sessionId.empty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }

    try {
        SQLite::Statement query(
            *m_db,
            "SELECT seq, turn_id, kind, time, data, truncated, orig_bytes FROM events "
            "WHERE session_id = ? ORDER BY seq ASC");
        query.bind(1, sessionId);

        std::vector<SessionEvent> events;
        while (query.executeStep()) {
            SessionEvent event;
            event.seq = query.getColumn(0).getInt64();
            event.turnId = query.getColumn(1).getString();
            const std::string kind = query.getColumn(2).getString();
            event.kind = eventKindFromName(kind).value_or(EventKind::Unknown);
            event.time = query.getColumn(3).getInt64();
            event.data = query.getColumn(4).getString();
            event.truncated = query.getColumn(5).getInt() != 0;
            if (!query.getColumn(6).isNull()) {
                event.origBytes = query.getColumn(6).getInt64();
            }
            events.push_back(std::move(event));
        }
        return events;
    } catch (const SQLite::Exception& e) {
        return std::unexpected(sqliteError(ErrorCode::DatabaseQuery, e));
    } catch (const std::exception& e) {
        return fail(ErrorCode::DatabaseQuery, e.what());
    }
}

Result<std::vector<SessionTurn>> SessionStore::loadTurns(const std::string& sessionId) const {
    auto events = loadEvents(sessionId);
    if (!events) {
        return std::unexpected(events.error());
    }

    std::vector<SessionTurn> turns;
    for (auto& event : *events) {
        if (turns.empty() || turns.back().turnId != event.turnId) {
            SessionTurn turn;
            turn.turnId = event.turnId;
            turns.push_back(std::move(turn));
        }
        turns.back().events.push_back(std::move(event));
    }
    return turns;
}

} // namespace mod::chatbot
