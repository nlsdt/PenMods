// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "ChatEngine.h"

#include <QHash>
#include <QJsonArray>
#include <QTimer>
#include <QJsonDocument>
#include <QJsonObject>
#include <QUuid>

#include <algorithm>
#include <utility>

namespace mod::chatbot {

namespace {

// A non-streaming response larger than this is treated as hostile; the device
// has very little RAM and a valid completion never comes close.
constexpr int kMaxResponseBytes = 8 << 20;

QByteArray excerpt(const QByteArray& body, int maxBytes = 300) {
    return body.size() <= maxBytes ? body : body.left(maxBytes) + "…";
}

struct ToolAccumulator {
    QString id;
    QString name;
    QString arguments;
};

} // namespace

struct ChatEngine::Private {
    HttpTransport transport;
    ChatCallbacks callbacks;
    std::unique_ptr<QTimer> watchdog;
    int                     idleTimeoutMs = 30000;

    std::unique_ptr<ProtocolAdapter> adapter;
    HttpCancel                       canceller;
    quint64                          generation = 0;
    bool                             busy       = false;
    bool                             streaming  = false;

    QString               messageId;
    QString               text;
    QString               reasoning;
    QString               error;
    bool                  failed = false;
    QHash<int, ToolAccumulator> tools;
    UsageDelta            usage;
    QStringList           images;
    QByteArray            bodyBuffer;

    void        handle(const StreamEvents& events, quint64 gen);
    void        finish(quint64 gen);
    void        abort(bool cancelled, const QString& error, quint64 gen);
    void        armWatchdog(quint64 gen);
    void        stopWatchdog();
    QString     buildToolCallsJson() const;
    void        resetState();
};

void ChatEngine::Private::stopWatchdog() {
    if (watchdog) watchdog->stop();
}

void ChatEngine::Private::armWatchdog(quint64 gen) {
    if (!watchdog) {
        watchdog = std::make_unique<QTimer>();
        watchdog->setSingleShot(true);
        QObject::connect(watchdog.get(), &QTimer::timeout, watchdog.get(), [this]() {
            if (!busy) return;
            abort(false, QStringLiteral("请求超时，请检查网络后重试"), generation);
        });
    }
    watchdog->start(idleTimeoutMs);
}

void ChatEngine::Private::resetState() {
    adapter.reset();
    canceller = nullptr;
    busy      = false;
    streaming = false;
    messageId.clear();
    text.clear();
    reasoning.clear();
    error.clear();
    failed = false;
    tools.clear();
    usage   = {};
    images.clear();
    bodyBuffer.clear();
}

QString ChatEngine::Private::buildToolCallsJson() const {
    if (tools.isEmpty()) return {};

    QList<int> indexes = tools.keys();
    std::sort(indexes.begin(), indexes.end());

    QJsonArray calls;
    for (const int index : indexes) {
        const ToolAccumulator& tool = tools.value(index);
        if (tool.name.isEmpty() && tool.arguments.isEmpty() && tool.id.isEmpty()) continue;
        const QString id = tool.id.isEmpty() ? messageId + QStringLiteral("_invalid_") + QString::number(index) : tool.id;
        calls.append(QJsonObject{
            {QStringLiteral("id"), id},
            {QStringLiteral("type"), QStringLiteral("function")},
            {QStringLiteral("function"),
             QJsonObject{{QStringLiteral("name"), tool.name}, {QStringLiteral("arguments"), tool.arguments}}},
        });
    }
    if (calls.isEmpty()) return {};
    return QString::fromUtf8(QJsonDocument(calls).toJson(QJsonDocument::Compact));
}

void ChatEngine::Private::handle(const StreamEvents& events, quint64 gen) {
    if (gen != generation || !busy) return;

    for (const auto& event : events) {
        if (gen != generation || !busy) return;

        switch (event.kind) {
            case StreamEventKind::Text:
                text += event.text;
                if (callbacks.textDelta) callbacks.textDelta(event.text);
                break;
            case StreamEventKind::Reasoning:
                reasoning += event.text;
                if (callbacks.reasoningDelta) callbacks.reasoningDelta(event.text);
                break;
            case StreamEventKind::ToolCall: {
                ToolAccumulator& tool = tools[event.toolCall.index];
                if (!event.toolCall.id.isEmpty()) tool.id = event.toolCall.id;
                if (event.toolCall.replaceName) {
                    tool.name = event.toolCall.name;
                } else {
                    tool.name += event.toolCall.name;
                }
                if (event.toolCall.replaceArguments) {
                    tool.arguments = event.toolCall.arguments;
                } else {
                    tool.arguments += event.toolCall.arguments;
                }
                break;
            }
            case StreamEventKind::ToolStatus:
                if (callbacks.toolStatus) callbacks.toolStatus(event.toolName, event.status);
                break;
            case StreamEventKind::Usage:
                if (event.usage.inputTokens > 0) usage.inputTokens = event.usage.inputTokens;
                if (event.usage.outputTokens > 0) usage.outputTokens = event.usage.outputTokens;
                if (event.usage.reasoningTokens > 0) usage.reasoningTokens = event.usage.reasoningTokens;
                if (event.usage.cacheReadTokens > 0) usage.cacheReadTokens = event.usage.cacheReadTokens;
                if (event.usage.cacheWriteTokens > 0) usage.cacheWriteTokens = event.usage.cacheWriteTokens;
                if (callbacks.usage) callbacks.usage(usage);
                break;
            case StreamEventKind::Image:
                if (!event.imageBase64.isEmpty()) images.append(event.imageBase64);
                break;
            case StreamEventKind::Error:
                failed = true;
                error  = event.text;
                break;
            case StreamEventKind::Done:
                finish(gen);
                return;
        }
    }
}

void ChatEngine::Private::finish(quint64 gen) {
    if (gen != generation || !busy) return;
    stopWatchdog();

    const bool    wasFailed = failed;
    const QString errorText = error;

    ChatResult result;
    result.messageId     = messageId;
    result.content       = text;
    result.reasoning     = reasoning;
    result.imagesBase64  = images;
    result.usage         = usage;
    result.failed        = wasFailed;
    result.error         = errorText;

    const QString toolCalls = buildToolCallsJson();
    result.toolCallsJson    = wasFailed ? QString() : toolCalls;

    busy      = false;
    canceller = nullptr;

    if (callbacks.finished) callbacks.finished(result);
}

void ChatEngine::Private::abort(bool cancelled, const QString& abortError, quint64 gen) {
    if (gen != generation || !busy) return;
    stopWatchdog();

    ChatResult result;
    result.messageId    = messageId;
    result.content      = text;
    result.reasoning    = reasoning;
    result.imagesBase64 = images;
    result.usage        = usage;
    result.cancelled    = cancelled;
    result.failed       = !cancelled;
    result.error        = abortError;

    const QString toolCalls = buildToolCallsJson();
    result.toolCallsJson    = toolCalls;

    busy      = false;
    auto stop = std::move(canceller);
    canceller = nullptr;

    // Cancel first so a synchronous transport callback cannot finalize twice.
    if (stop) stop();
    if (callbacks.finished) callbacks.finished(result);
}

ChatEngine::ChatEngine() : d(std::make_unique<Private>()) {}

ChatEngine::~ChatEngine() {
    d->stopWatchdog();
    if (d->canceller) d->canceller();
}

void ChatEngine::setTransport(HttpTransport transport) { d->transport = std::move(transport); }

void ChatEngine::setCallbacks(ChatCallbacks callbacks) { d->callbacks = std::move(callbacks); }

void ChatEngine::setIdleTimeoutMs(int timeoutMs) {
    d->idleTimeoutMs = timeoutMs > 0 ? timeoutMs : 30000;
}

bool ChatEngine::send(const ChatRequest& request) {
    if (d->busy) return false;

    auto adapter = ProtocolAdapter::create(request.protocol);
    if (!adapter) {
        ChatResult result;
        result.failed = true;
        result.error  = QStringLiteral("未知的 API 协议: ") + request.protocol;
        if (d->callbacks.finished) d->callbacks.finished(result);
        return false;
    }

    d->resetState();
    const quint64 gen = ++d->generation;
    d->adapter        = std::move(adapter);
    d->streaming      = request.options.stream;
    d->messageId      = QUuid::createUuid().toString(QUuid::WithoutBraces);
    d->busy           = true;
    d->armWatchdog(gen);

    if (!d->transport) {
        d->failed = true;
        d->error  = QStringLiteral("网络传输未初始化");
        d->handle({StreamEvent::error(d->error), StreamEvent::done()}, gen);
        return true;
    }

    HttpRequest http;
    http.url           = QUrl(request.endpoint);
    http.body          = d->adapter->buildRequest(request.messages, request.options);
    http.authorization = "Bearer " + request.apiKey.toUtf8();

    if (d->callbacks.streamStart) d->callbacks.streamStart(d->messageId);

    HttpCancel cancelHandle = d->transport(
        http,
        [this, gen](const QByteArray& chunk) {
            if (gen != d->generation || !d->busy) return;
            d->armWatchdog(gen);
            if (d->streaming) {
                d->handle(d->adapter->feed(chunk), gen);
                return;
            }
            if (d->bodyBuffer.size() + chunk.size() > kMaxResponseBytes) {
                d->failed = true;
                d->error  = QStringLiteral("响应体过大，已中止");
                d->handle({StreamEvent::error(d->error), StreamEvent::done()}, gen);
                return;
            }
            d->bodyBuffer += chunk;
        },
        [this, gen](int status, const QByteArray& body, const QString& error) {
            if (gen != d->generation || !d->busy) return;
            d->stopWatchdog();
            // The request is over; dropping the handle without cancelling avoids
            // aborting a reply that just completed normally.
            d->canceller = nullptr;

            if (!error.isEmpty()) {
                const QString prefix = status > 0 ? QStringLiteral("HTTP %1: ").arg(status) : QString();
                d->abort(false, prefix + error, gen);
                return;
            }
            if (status >= 400) {
                const QString detail = QString::fromUtf8(excerpt(body));
                d->abort(false, QStringLiteral("HTTP %1: %2").arg(status).arg(detail), gen);
                return;
            }

            if (d->streaming) {
                if (!body.isEmpty()) d->handle(d->adapter->feed(body), gen);
                if (!d->busy) return;
                d->handle(d->adapter->finish(), gen);
                return;
            }

            if (d->bodyBuffer.size() + body.size() > kMaxResponseBytes) {
                d->abort(false, QStringLiteral("响应体过大，已中止"), gen);
                return;
            }
            d->bodyBuffer += body;
            d->handle(d->adapter->parseResponse(d->bodyBuffer), gen);
        });

    // A synchronous transport may already have finished the request.
    if (gen == d->generation && d->busy) {
        d->canceller = std::move(cancelHandle);
    } else if (cancelHandle) {
        cancelHandle();
    }
    return true;
}

void ChatEngine::cancel() {
    if (!d->busy) return;
    const quint64 gen = d->generation;
    d->abort(true, QString(), gen);
}

bool ChatEngine::busy() const { return d->busy; }

QString ChatEngine::responseMessageId() const { return d->messageId; }

} // namespace mod::chatbot
