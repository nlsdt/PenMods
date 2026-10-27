// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "SessionRepository.h"

#include <QDateTime>
#include <QJsonDocument>
#include <QUuid>

#include <nlohmann/json.hpp>

namespace mod::chatbot {

namespace {

using json = nlohmann::json;

json messageDataToJson(const MessageData& msg) {
    json obj;
    obj["messageId"] = msg.messageId.toStdString();

    if (!msg.toolStates.isEmpty()) {
        const json states = json::parse(
            QJsonDocument::fromVariant(msg.toolStates).toJson().toStdString(),
            nullptr,
            false);
        if (!states.is_discarded()) {
            obj["toolStates"] = states;
        }
    }

    obj["role"]    = msg.role.toStdString();
    obj["content"] = msg.content.toStdString();
    if (!msg.toolCallId.isEmpty()) obj["toolCallId"] = msg.toolCallId.toStdString();
    if (!msg.toolCallsJson.isEmpty()) obj["toolCallsJson"] = msg.toolCallsJson.toStdString();
    if (!msg.reasoning.isEmpty()) obj["reasoning"] = msg.reasoning.toStdString();

    if (msg.isMultimodal()) {
        json parts = json::array();
        for (const auto& part : msg.parts) {
            if (part.type == "image_url" && part.url.startsWith("data:", Qt::CaseInsensitive)) continue;

            json p;
            p["type"]      = part.type.toStdString();
            p["text"]      = part.text.toStdString();
            p["url"]       = part.url.toStdString();
            p["data"]      = part.data.toStdString();
            p["format"]    = part.format.toStdString();
            p["localPath"] = part.localPath.toStdString();
            p["name"]      = part.name.toStdString();
            p["mimeType"]  = part.mimeType.toStdString();
            p["language"]  = part.language.toStdString();
            p["size"]      = part.size;
            parts.push_back(std::move(p));
        }
        if (!parts.empty()) obj["parts"] = std::move(parts);
    }
    return obj;
}

MessageData messageDataFromJson(const json& obj) {
    MessageData msg;
    if (obj.contains("messageId") && obj["messageId"].is_string() && !obj["messageId"].get<std::string>().empty()) {
        msg.messageId = QString::fromStdString(obj["messageId"]);
    } else {
        msg.messageId = QUuid::createUuid().toString(QUuid::WithoutBraces);
    }

    if (obj.contains("toolStates") && obj["toolStates"].is_array()) {
        msg.toolStates = QJsonDocument::fromJson(QByteArray::fromStdString(obj["toolStates"].dump()))
                             .toVariant()
                             .toList();
    }

    msg.role    = QString::fromStdString(obj.value("role", ""));
    msg.content = QString::fromStdString(obj.value("content", ""));
    if (obj.contains("toolCallId")) msg.toolCallId = QString::fromStdString(obj["toolCallId"]);
    if (obj.contains("toolCallsJson")) msg.toolCallsJson = QString::fromStdString(obj["toolCallsJson"]);
    if (obj.contains("reasoning")) msg.reasoning = QString::fromStdString(obj["reasoning"]);

    if (obj.contains("parts") && obj["parts"].is_array()) {
        for (const auto& p : obj["parts"]) {
            MessagePart part;
            part.type      = QString::fromStdString(p.value("type", "text"));
            part.text      = QString::fromStdString(p.value("text", ""));
            part.url       = QString::fromStdString(p.value("url", ""));
            part.data      = QString::fromStdString(p.value("data", ""));
            part.format    = QString::fromStdString(p.value("format", ""));
            part.localPath = QString::fromStdString(p.value("localPath", ""));
            part.name      = QString::fromStdString(p.value("name", ""));
            part.mimeType  = QString::fromStdString(p.value("mimeType", ""));
            part.language  = QString::fromStdString(p.value("language", ""));
            part.size      = p.value("size", 0LL);
            msg.parts.append(part);
        }
        if (msg.content.isEmpty()) {
            for (const auto& part : msg.parts) {
                if (part.type == "text" && !part.text.isEmpty()) {
                    msg.content = part.text;
                    break;
                }
            }
        }
    }
    return msg;
}

EventKind kindFor(const MessageData& msg) {
    if (msg.role == "user") return EventKind::UserMessage;
    if (msg.role == "tool") return EventKind::ToolResult;
    if (!msg.toolCallsJson.isEmpty()) return EventKind::ToolCall;
    if (!msg.reasoning.isEmpty() && msg.content.isEmpty()) return EventKind::AssistantReasoning;
    return EventKind::AssistantText;
}

bool isMessageKind(EventKind kind) {
    return kind != EventKind::RequestHeader && kind != EventKind::Unknown;
}

QString msToIso(qint64 ms) {
    return QDateTime::fromMSecsSinceEpoch(ms).toString(Qt::ISODate);
}

// turn_id of message `index`: the id of the nearest user message at or before
// it, or the first message's id when the session has no user turn yet.
std::string turnIdAt(const QVector<MessageData>& messages, int index) {
    for (int i = index; i >= 0; --i) {
        if (messages[i].role == "user") return messages[i].messageId.toStdString();
    }
    for (const auto& message : messages) {
        if (!message.messageId.isEmpty()) return message.messageId.toStdString();
    }
    return QUuid::createUuid().toString(QUuid::WithoutBraces).toStdString();
}

NewEvent makeEvent(const MessageData& msg, std::string turnId, qint64 nowMs) {
    NewEvent event;
    event.turnId = std::move(turnId);
    event.kind   = kindFor(msg);
    event.time   = nowMs;
    event.data   = messageDataToJson(msg).dump();
    return event;
}

} // namespace

SessionRepository::SessionRepository(std::unique_ptr<SessionStore> store) : m_store(std::move(store)) {}

Result<std::unique_ptr<SessionRepository>> SessionRepository::open(const QString& dbPath) {
    if (dbPath.isEmpty()) {
        return fail(ErrorCode::InvalidArgument, "database path is empty");
    }
    auto store = SessionStore::open(dbPath.toStdString());
    if (!store) {
        return std::unexpected(store.error());
    }
    return std::make_unique<SessionRepository>(std::move(*store));
}

Result<LoadedSessions> SessionRepository::load() const {
    auto metas = m_store->listSessions();
    if (!metas) {
        return std::unexpected(metas.error());
    }

    LoadedSessions loaded;
    loaded.sessions.reserve(metas->size());

    for (const auto& meta : *metas) {
        auto events = m_store->loadEvents(meta.id);
        if (!events) {
            return std::unexpected(events.error());
        }

        StoredSession session;
        session.id        = QString::fromStdString(meta.id);
        session.title     = QString::fromStdString(meta.title);
        session.createdAt = msToIso(meta.createdAt);
        session.updatedAt = msToIso(meta.updatedAt);

        for (const auto& event : *events) {
            if (!isMessageKind(event.kind)) continue;
            const json parsed = json::parse(event.data, nullptr, false);
            if (parsed.is_discarded() || !parsed.is_object()) {
                continue;
            }
            MessageData msg = messageDataFromJson(parsed);
            if (msg.role.isEmpty()) {
                continue;
            }
            session.messages.append(std::move(msg));
        }
        loaded.sessions.push_back(std::move(session));
    }

    auto active = m_store->getState("active_session_id");
    if (!active) {
        return std::unexpected(active.error());
    }
    if (active->has_value()) {
        loaded.activeSessionId = QString::fromStdString(active->value());
    }
    return loaded;
}

Result<void> SessionRepository::createSession(const QString& id, const QString& title, qint64 nowMs) {
    if (id.isEmpty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }
    auto created = m_store->createSession(
        id.toStdString(),
        title.isEmpty() ? std::string{} : title.toStdString(),
        std::nullopt,
        nowMs);
    if (!created) {
        return std::unexpected(created.error());
    }
    return {};
}

Result<void> SessionRepository::deleteSession(const QString& id) {
    if (id.isEmpty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }
    return m_store->deleteSession(id.toStdString());
}

Result<void> SessionRepository::renameSession(const QString& id, const QString& title, qint64 nowMs) {
    if (id.isEmpty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }
    return m_store->renameSession(id.toStdString(), title.toStdString(), nowMs);
}

Result<void> SessionRepository::setActiveSession(const QString& id) {
    if (id.isEmpty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }
    return m_store->setState("active_session_id", id.toStdString());
}

Result<void> SessionRepository::appendMessages(
    const QString& sessionId,
    const QVector<MessageData>& messages,
    qint64 nowMs) {
    if (sessionId.isEmpty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }
    if (messages.isEmpty()) {
        return {};
    }

    auto lastTurn = m_store->lastUserTurnId(sessionId.toStdString());
    if (!lastTurn) {
        return std::unexpected(lastTurn.error());
    }
    std::string currentTurn = lastTurn->value_or(std::string{});

    std::vector<NewEvent> events;
    events.reserve(static_cast<std::size_t>(messages.size()));
    for (const auto& msg : messages) {
        if (msg.role == "system") {
            return fail(ErrorCode::InvalidArgument, "system messages are not part of the session log");
        }
        if (msg.role == "user") {
            currentTurn = msg.messageId.toStdString();
        }
        const std::string turnId = currentTurn.empty() ? msg.messageId.toStdString() : currentTurn;
        events.push_back(makeEvent(msg, turnId, nowMs));
    }

    auto appended = m_store->appendEvents(sessionId.toStdString(), events, nowMs);
    if (!appended) {
        return std::unexpected(appended.error());
    }
    return {};
}

Result<void> SessionRepository::syncTail(
    const QString& sessionId,
    const QVector<MessageData>& messages,
    int keepCount,
    qint64 nowMs) {
    if (sessionId.isEmpty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }
    if (keepCount < 0) {
        return fail(ErrorCode::InvalidArgument, "keepCount is negative");
    }
    if (keepCount > messages.size()) {
        keepCount = messages.size();
    }

    auto events = m_store->loadEvents(sessionId.toStdString());
    if (!events) {
        return std::unexpected(events.error());
    }

    int          seen   = 0;
    qint64       cutoff = -1;
    for (const auto& event : *events) {
        if (!isMessageKind(event.kind)) continue;
        if (seen == keepCount) {
            cutoff = event.seq;
            break;
        }
        ++seen;
    }

    if (cutoff >= 0) {
        auto removed = m_store->deleteEventsFrom(sessionId.toStdString(), cutoff, nowMs);
        if (!removed) {
            return removed;
        }
    }

    if (keepCount >= messages.size()) {
        // Pure truncation: the delete above already refreshed updated_at/last_seq.
        return {};
    }

    QVector<MessageData> tail = messages.mid(keepCount);
    std::vector<NewEvent> tailEvents;
    tailEvents.reserve(static_cast<std::size_t>(tail.size()));
    for (int i = 0; i < tail.size(); ++i) {
        if (tail[i].role == "system") {
            return fail(ErrorCode::InvalidArgument, "system messages are not part of the session log");
        }
        tailEvents.push_back(makeEvent(tail[i], turnIdAt(messages, keepCount + i), nowMs));
    }

    auto appended = m_store->appendEvents(sessionId.toStdString(), tailEvents, nowMs);
    if (!appended) {
        return std::unexpected(appended.error());
    }
    return {};
}

Result<void> SessionRepository::clearMessages(const QString& sessionId, qint64 nowMs) {
    if (sessionId.isEmpty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }
    auto events = m_store->loadEvents(sessionId.toStdString());
    if (!events) {
        return std::unexpected(events.error());
    }
    if (events->empty()) {
        return {};
    }
    return m_store->deleteEventsFrom(sessionId.toStdString(), events->front().seq, nowMs);
}

Result<void> SessionRepository::addUsage(const QString& sessionId, const UsageCounters& usage) {
    if (sessionId.isEmpty()) {
        return fail(ErrorCode::InvalidArgument, "session id is empty");
    }
    return m_store->addUsage(sessionId.toStdString(), usage);
}

} // namespace mod::chatbot
