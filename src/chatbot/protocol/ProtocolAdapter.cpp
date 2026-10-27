// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "ProtocolAdapter.h"

#include "ChatCompletionsAdapter.h"
#include "ResponsesAdapter.h"

namespace mod::chatbot {

namespace {

// Strip the SSE field name. Accepts both "data: {...}" and "data:{...}".
bool ssePayload(const QString& line, QString* payload) {
    if (!line.startsWith(QLatin1String("data:"), Qt::CaseInsensitive)) return false;
    QString rest = line.mid(5);
    if (rest.startsWith(QLatin1Char(' '))) rest.remove(0, 1);
    *payload = rest;
    return true;
}

} // namespace

QJsonArray serializeMessagesForRequest(
    const QVector<MessageData>& messages,
    bool                        capVision,
    const UrlResolver&          resolveUrl) {
    QJsonArray array;
    for (const auto& message : messages) {
        array.append(messageToRequestJson(message, capVision, resolveUrl));
    }
    return array;
}

std::unique_ptr<ProtocolAdapter> ProtocolAdapter::create(const QString& protocol) {
    if (protocol == QLatin1String("responses")) {
        return std::make_unique<ResponsesAdapter>();
    }
    if (protocol.isEmpty() || protocol == QLatin1String("chat_completions")
        || protocol == QLatin1String("chat-completions")) {
        return std::make_unique<ChatCompletionsAdapter>();
    }
    return nullptr;
}

StreamEvents ProtocolAdapter::feed(const QByteArray& chunk) {
    StreamEvents out;
    if (m_done) return out;

    m_pending.append(chunk);

    int newline = m_pending.indexOf('\n');
    while (newline >= 0) {
        QByteArray line = m_pending.left(newline);
        m_pending.remove(0, newline + 1);
        if (line.endsWith('\r')) line.chop(1);

        QString payload;
        if (ssePayload(QString::fromUtf8(line), &payload) && !payload.isEmpty()) {
            handleData(payload, out);
        }
        if (m_done) break;

        newline = m_pending.indexOf('\n');
    }
    return out;
}

StreamEvents ProtocolAdapter::finish() {
    StreamEvents out;
    if (m_done) return out;

    // A stream that closed without a trailing newline may still end in a complete
    // JSON payload; try it before synthesising the terminal event.
    const QByteArray tail = m_pending.trimmed();
    m_pending.clear();
    if (!tail.isEmpty()) {
        QString payload;
        if (ssePayload(QString::fromUtf8(tail), &payload) && !payload.isEmpty()) {
            handleData(payload, out);
        }
    }

    markDone(out);
    return out;
}

void ProtocolAdapter::reset() {
    m_done = false;
    m_pending.clear();
}

void ProtocolAdapter::markDone(StreamEvents& out) {
    if (m_done) return;
    m_done = true;
    out.append(StreamEvent::done());
}

} // namespace mod::chatbot
