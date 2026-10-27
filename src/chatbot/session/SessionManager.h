// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include "SessionRepository.h"

#include <QMap>
#include <QString>
#include <QVector>

#include <memory>

namespace mod::chatbot {

// In-memory session model plus write-through policy. The facade keeps no session
// state of its own: every mutation here is persisted first (event-level append or
// tail rewrite) and only applied to memory when the write succeeded, so a failed
// write can never leave RAM and disk disagreeing.
class SessionManager {
public:
    [[nodiscard]] static Result<std::unique_ptr<SessionManager>> open(const QString& dbPath);

    SessionManager(const SessionManager&) = delete;
    SessionManager& operator=(const SessionManager&) = delete;

    [[nodiscard]] const QMap<QString, StoredSession>& sessions() const { return m_sessions; }
    [[nodiscard]] QString                             activeSessionId() const { return m_activeSessionId; }
    [[nodiscard]] bool                                hasSession(const QString& id) const;
    [[nodiscard]] const StoredSession*                session(const QString& id) const;
    [[nodiscard]] QVector<MessageData>                messages(const QString& id) const;

    [[nodiscard]] Result<QString> createSession(const QString& title = {});
    [[nodiscard]] Result<void>    deleteSession(const QString& id);
    [[nodiscard]] Result<void>    renameSession(const QString& id, const QString& title);
    [[nodiscard]] Result<void>    switchSession(const QString& id);

    [[nodiscard]] Result<void> appendMessage(const QString& sessionId, const MessageData& message);
    // Replaces one message in place (tool states are updated while a batch runs).
    [[nodiscard]] Result<void> updateMessage(
        const QString&       sessionId,
        const QString&       messageId,
        const MessageData&   updated);
    [[nodiscard]] Result<void>
    replaceTail(const QString& sessionId, int keepCount, const QVector<MessageData>& tail);
    [[nodiscard]] Result<void> clearMessages(const QString& sessionId);
    // Adds one request's token usage to the persisted session counters. Purely a
    // write-through to SQLite; nothing in StoredSession mirrors these totals.
    [[nodiscard]] Result<void> recordUsage(const QString& sessionId, const UsageCounters& usage);

    // Internal: prefer open(). Public only so std::make_unique can construct it.
    SessionManager(std::unique_ptr<SessionRepository> repo, LoadedSessions loaded);

private:

    [[nodiscard]] Result<void> ensureActiveSession();

    std::unique_ptr<SessionRepository> m_repo;
    QMap<QString, StoredSession>       m_sessions;
    QString                            m_activeSessionId;
};

} // namespace mod::chatbot
