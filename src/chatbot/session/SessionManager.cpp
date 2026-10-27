// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "SessionManager.h"

#include <QDateTime>
#include <QUuid>

namespace mod::chatbot {

namespace {

QString nowIso() {
    return QDateTime::currentDateTime().toString(Qt::ISODate);
}

QString newId() {
    return QUuid::createUuid().toString(QUuid::WithoutBraces);
}

} // namespace

SessionManager::SessionManager(std::unique_ptr<SessionRepository> repo, LoadedSessions loaded)
    : m_repo(std::move(repo)), m_activeSessionId(std::move(loaded.activeSessionId)) {
    for (auto& session : loaded.sessions) {
        if (!session.id.isEmpty()) {
            m_sessions.insert(session.id, std::move(session));
        }
    }
}

Result<std::unique_ptr<SessionManager>> SessionManager::open(const QString& dbPath) {
    auto repo = SessionRepository::open(dbPath);
    if (!repo) {
        return std::unexpected(repo.error());
    }

    auto loaded = (*repo)->load();
    if (!loaded) {
        return std::unexpected(loaded.error());
    }

    auto manager = std::make_unique<SessionManager>(std::move(*repo), std::move(*loaded));
    auto ensured = manager->ensureActiveSession();
    if (!ensured) {
        return std::unexpected(ensured.error());
    }
    return manager;
}

Result<void> SessionManager::ensureActiveSession() {
    if (m_sessions.isEmpty()) {
        auto created = createSession("新对话");
        if (!created) {
            return std::unexpected(created.error());
        }
        return {};
    }
    if (m_sessions.contains(m_activeSessionId)) return {};

    m_activeSessionId = m_sessions.firstKey();
    return m_repo->setActiveSession(m_activeSessionId);
}

bool SessionManager::hasSession(const QString& id) const {
    return m_sessions.contains(id);
}

const StoredSession* SessionManager::session(const QString& id) const {
    const auto it = m_sessions.constFind(id);
    return it == m_sessions.constEnd() ? nullptr : &it.value();
}

QVector<MessageData> SessionManager::messages(const QString& id) const {
    const StoredSession* stored = session(id);
    return stored ? stored->messages : QVector<MessageData>{};
}

Result<QString> SessionManager::createSession(const QString& title) {
    StoredSession session;
    session.id        = newId();
    session.title     = title.isEmpty() ? QStringLiteral("新对话") : title;
    session.createdAt = nowIso();
    session.updatedAt = session.createdAt;

    auto created = m_repo->createSession(session.id, session.title);
    if (!created) {
        return std::unexpected(created.error());
    }
    auto activated = m_repo->setActiveSession(session.id);
    if (!activated) {
        // The session exists but is not active; drop it again so memory stays clean.
        (void)m_repo->deleteSession(session.id);
        return std::unexpected(activated.error());
    }

    const QString id = session.id;
    m_sessions.insert(id, std::move(session));
    m_activeSessionId = id;
    return id;
}

Result<void> SessionManager::deleteSession(const QString& id) {
    if (!m_sessions.contains(id)) {
        return fail(ErrorCode::NotFound, "session not found: " + id.toStdString());
    }
    if (m_sessions.size() <= 1) {
        return fail(ErrorCode::InvalidArgument, "cannot delete the only session");
    }

    auto removed = m_repo->deleteSession(id);
    if (!removed) {
        return removed;
    }
    m_sessions.remove(id);

    if (m_activeSessionId == id) {
        m_activeSessionId = m_sessions.firstKey();
        auto stored       = m_repo->setActiveSession(m_activeSessionId);
        if (!stored) {
            return stored;
        }
    }
    return {};
}

Result<void> SessionManager::renameSession(const QString& id, const QString& title) {
    const auto it = m_sessions.find(id);
    if (it == m_sessions.end()) {
        return fail(ErrorCode::NotFound, "session not found: " + id.toStdString());
    }

    auto renamed = m_repo->renameSession(id, title);
    if (!renamed) {
        return renamed;
    }
    it->title     = title;
    it->updatedAt = nowIso();
    return {};
}

Result<void> SessionManager::switchSession(const QString& id) {
    if (!m_sessions.contains(id)) {
        return fail(ErrorCode::NotFound, "session not found: " + id.toStdString());
    }
    if (m_activeSessionId == id) return {};

    auto stored = m_repo->setActiveSession(id);
    if (!stored) {
        return stored;
    }
    m_activeSessionId = id;
    return {};
}

Result<void> SessionManager::appendMessage(const QString& sessionId, const MessageData& message) {
    const auto it = m_sessions.find(sessionId);
    if (it == m_sessions.end()) {
        return fail(ErrorCode::NotFound, "session not found: " + sessionId.toStdString());
    }

    MessageData stored = message;
    if (stored.messageId.isEmpty()) {
        stored.messageId = newId();
    }

    auto appended = m_repo->appendMessages(sessionId, {stored});
    if (!appended) {
        return appended;
    }

    it->messages.append(stored);
    it->updatedAt = nowIso();
    return {};
}

Result<void> SessionManager::updateMessage(
    const QString& sessionId,
    const QString& messageId,
    const MessageData& updated) {
    const auto it = m_sessions.find(sessionId);
    if (it == m_sessions.end()) {
        return fail(ErrorCode::NotFound, "session not found: " + sessionId.toStdString());
    }

    int index = -1;
    for (int i = 0; i < it->messages.size(); ++i) {
        if (it->messages[i].messageId != messageId) continue;
        index = i;
        break;
    }
    if (index < 0) {
        return fail(ErrorCode::NotFound, "message not found: " + messageId.toStdString());
    }

    QVector<MessageData> next = it->messages;
    next[index] = updated;

    auto synced = m_repo->syncTail(sessionId, next, index);
    if (!synced) {
        return synced;
    }
    it->messages  = std::move(next);
    it->updatedAt = nowIso();
    return {};
}

Result<void> SessionManager::replaceTail(
    const QString& sessionId,
    int keepCount,
    const QVector<MessageData>& tail) {
    const auto it = m_sessions.find(sessionId);
    if (it == m_sessions.end()) {
        return fail(ErrorCode::NotFound, "session not found: " + sessionId.toStdString());
    }
    if (keepCount < 0 || keepCount > it->messages.size()) {
        return fail(ErrorCode::InvalidArgument, "keepCount out of range");
    }

    QVector<MessageData> next = it->messages.mid(0, keepCount);
    next += tail;

    auto synced = m_repo->syncTail(sessionId, next, keepCount);
    if (!synced) {
        return synced;
    }

    it->messages  = std::move(next);
    it->updatedAt = nowIso();
    return {};
}

Result<void> SessionManager::clearMessages(const QString& sessionId) {
    const auto it = m_sessions.find(sessionId);
    if (it == m_sessions.end()) {
        return fail(ErrorCode::NotFound, "session not found: " + sessionId.toStdString());
    }

    auto cleared = m_repo->clearMessages(sessionId);
    if (!cleared) {
        return cleared;
    }
    it->messages.clear();
    it->updatedAt = nowIso();
    return {};
}

Result<void> SessionManager::recordUsage(const QString& sessionId, const UsageCounters& usage) {
    if (!m_sessions.contains(sessionId)) {
        return fail(ErrorCode::NotFound, "session not found: " + sessionId.toStdString());
    }
    return m_repo->addUsage(sessionId, usage);
}

} // namespace mod::chatbot
