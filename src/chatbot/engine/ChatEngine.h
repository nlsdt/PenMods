// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include "chatbot/protocol/ProtocolAdapter.h"
#include "chatbot/protocol/StreamEvent.h"

#include <QByteArray>
#include <QString>
#include <QStringList>
#include <QUrl>
#include <QVector>

#include <functional>
#include <memory>

namespace mod::chatbot {

struct HttpRequest {
    QUrl       url;
    QByteArray body;
    QByteArray authorization;
};

// One model attempt. The transport owns the wire; it calls onData for every
// received chunk, then onDone exactly once. `cancel` aborts the request and must
// not invoke either callback afterwards.
using HttpCancel = std::function<void()>;
using HttpTransport = std::function<HttpCancel(
    const HttpRequest&                     request,
    std::function<void(const QByteArray&)> onData,
    std::function<void(int status, const QByteArray& body, const QString& error)> onDone)>;

struct ChatRequest {
    QString              endpoint;
    QString              apiKey;
    QString              protocol = QStringLiteral("chat_completions");
    QVector<MessageData> messages;
    RequestOptions       options;
};

struct ChatResult {
    QString   messageId;
    QString   content;
    QString   reasoning;
    QString   toolCallsJson;
    QStringList imagesBase64;
    UsageDelta usage;
    bool      cancelled = false;
    bool      failed    = false;
    QString   error;
};

struct ChatCallbacks {
    std::function<void(const QString& messageId)> streamStart;
    std::function<void(const QString& text)>      textDelta;
    std::function<void(const QString& text)>      reasoningDelta;
    std::function<void(const UsageDelta& usage)>  usage;
    std::function<void(const QString& toolCallsJson)> toolCalls;
    // Responses-API server tools (web_search_call, image_generation_call, ...).
    std::function<void(const QString& toolName, const QString& status)> toolStatus;
    std::function<void(const ChatResult& result)>     finished;
};

// Owns the lifecycle of one request at a time: builds the body through the
// protocol adapter, feeds stream chunks, accumulates text/reasoning/tool calls,
// and reports exactly one terminal result. It never touches sessions, tools or
// QML; callers persist/execute based on the callbacks.
class ChatEngine {
public:
    ChatEngine();
    ~ChatEngine();

    ChatEngine(const ChatEngine&) = delete;
    ChatEngine& operator=(const ChatEngine&) = delete;

    void setTransport(HttpTransport transport);
    void setCallbacks(ChatCallbacks callbacks);
    // Aborts a request that receives no bytes for this long. Default 30s.
    void setIdleTimeoutMs(int timeoutMs);

    // Returns false when a request is already in flight or the protocol is
    // unknown (in which case `finished` is invoked with a failure).
    bool send(const ChatRequest& request);
    void cancel();

    [[nodiscard]] bool    busy() const;
    [[nodiscard]] QString responseMessageId() const;

private:
    struct Private;
    std::unique_ptr<Private> d;
};

} // namespace mod::chatbot
