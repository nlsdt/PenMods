// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include "SessionStore.h"
#include "chatbot/core/MessageData.h"

#include <QString>
#include <QVector>

#include <memory>
#include <vector>

namespace mod::chatbot {

// One persisted message, reconstructed from the event log. messages keep the
// same shape the QML model already speaks; the event store adds the sequencing
// and the append/replace primitives underneath it.
struct StoredSession {
    QString              id;
    QString              title;
    QString              createdAt;
    QString              updatedAt;
    QVector<MessageData> messages;
};

struct LoadedSessions {
    std::vector<StoredSession> sessions;
    QString                    activeSessionId;
};

// The only place where MessageData meets SessionStore. Writes are event-level:
// appendMessages() appends new events, syncTail() rewrites just the affected
// tail (edit / delete / regenerate / truncate). There is deliberately no
// "save the whole session map" call.
class SessionRepository {
public:
    explicit SessionRepository(std::unique_ptr<SessionStore> store);

    [[nodiscard]] static Result<std::unique_ptr<SessionRepository>> open(const QString& dbPath);

    [[nodiscard]] Result<LoadedSessions> load() const;

    [[nodiscard]] Result<void> createSession(
        const QString& id,
        const QString& title,
        qint64         nowMs = nowMillis());
    [[nodiscard]] Result<void> deleteSession(const QString& id);
    [[nodiscard]] Result<void> renameSession(
        const QString& id,
        const QString& title,
        qint64         nowMs = nowMillis());
    [[nodiscard]] Result<void> setActiveSession(const QString& id);

    [[nodiscard]] Result<void> appendMessages(
        const QString&              sessionId,
        const QVector<MessageData>& messages,
        qint64                      nowMs = nowMillis());

    // Delete the persisted events from message index keepCount onward and append
    // `messages[keepCount..]`. Callers pass the full authoritative vector so the
    // turn grouping of the rewritten tail stays correct.
    [[nodiscard]] Result<void> syncTail(
        const QString&              sessionId,
        const QVector<MessageData>& messages,
        int                         keepCount,
        qint64                      nowMs = nowMillis());

    [[nodiscard]] Result<void> clearMessages(const QString& sessionId, qint64 nowMs = nowMillis());

    // Accumulates one request's token usage into the session row (see
    // SessionStore::addUsage). Missing sessions yield NotFound; zero usage is a no-op.
    [[nodiscard]] Result<void> addUsage(const QString& sessionId, const UsageCounters& usage);

private:
    std::unique_ptr<SessionStore> m_store;
};

} // namespace mod::chatbot
