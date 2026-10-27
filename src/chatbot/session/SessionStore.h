// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include "SessionTypes.h"

#include <memory>
#include <string>
#include <vector>

namespace SQLite {
class Database;
class Statement;
} // namespace SQLite

namespace mod::chatbot {

// The single SQLite adapter boundary. Everything above this class sees Result<T>,
// never SQLite::Exception. The constructor is public only so std::make_unique can
// create it; call open() instead.
class SessionStore {
public:
    explicit SessionStore(std::unique_ptr<SQLite::Database> db);
    ~SessionStore();

    SessionStore(const SessionStore&) = delete;
    SessionStore& operator=(const SessionStore&) = delete;

    [[nodiscard]] static Result<std::unique_ptr<SessionStore>> open(const std::string& path);

    [[nodiscard]] Result<SessionMeta> createSession(
        std::string id,
        std::string title = {},
        std::optional<std::string> model = std::nullopt,
        std::int64_t nowMs = nowMillis());

    [[nodiscard]] Result<void> renameSession(const std::string& id, std::string title, std::int64_t nowMs = nowMillis());
    [[nodiscard]] Result<void> deleteSession(const std::string& id);

    [[nodiscard]] Result<SessionMeta>              getSession(const std::string& id) const;
    [[nodiscard]] Result<std::vector<SessionMeta>> listSessions() const;

    [[nodiscard]] Result<void> upsertSession(const SessionMeta& meta, std::int64_t nowMs = nowMillis());

    // Adds one request's token usage to the session's running counters. All
    // counters must be non-negative; an all-zero usage is a no-op. The row is
    // left untouched when it does not exist (NotFound), so a late callback for a
    // deleted session cannot resurrect it.
    [[nodiscard]] Result<void> addUsage(const std::string& sessionId, const UsageCounters& usage);

    [[nodiscard]] Result<std::vector<SessionEvent>> appendEvents(
        const std::string& sessionId,
        const std::vector<NewEvent>& events,
        std::int64_t nowMs = nowMillis());

    // Remove every event with seq >= minSeq and recompute last_seq/message_count,
    // so the next appendEvents reuses the freed sequence numbers. This is the
    // edit/regenerate/truncate primitive: only the affected tail is rewritten.
    [[nodiscard]] Result<void> deleteEventsFrom(
        const std::string& sessionId,
        std::int64_t minSeq,
        std::int64_t nowMs = nowMillis());

    // turn_id of the newest user-message event, i.e. the turn a freshly appended
    // assistant/tool message belongs to. nullopt when the session has no user turn.
    [[nodiscard]] Result<std::optional<std::string>> lastUserTurnId(const std::string& sessionId) const;

    [[nodiscard]] Result<std::optional<std::string>> getState(const std::string& key) const;
    [[nodiscard]] Result<void>                      setState(const std::string& key, std::string value);

    [[nodiscard]] Result<std::vector<SessionEvent>> loadEvents(const std::string& sessionId) const;
    [[nodiscard]] Result<std::vector<SessionTurn>>  loadTurns(const std::string& sessionId) const;

private:
    [[nodiscard]] Result<void> initSchema();

    static SessionMeta readMeta(const SQLite::Statement& query);

    std::unique_ptr<SQLite::Database> m_db;
};

} // namespace mod::chatbot
