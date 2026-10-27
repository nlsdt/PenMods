// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "ChatCompletionsAdapter.h"

#include "ProtocolCommon.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

namespace mod::chatbot {

namespace {

QJsonArray withBuiltinTools(const QJsonArray& tools, const QJsonArray& builtinTools) {
    if (builtinTools.isEmpty()) return tools;
    QJsonArray merged = tools;
    for (const auto& tool : builtinTools) merged.append(tool);
    return merged;
}

ToolCallDelta fullToolCall(int index, const QJsonObject& call) {
    const QJsonObject function = call.value(QLatin1String("function")).toObject();
    ToolCallDelta     delta;
    delta.index            = index;
    delta.id               = call.value(QLatin1String("id")).toString();
    delta.name             = function.value(QLatin1String("name")).toString();
    delta.arguments        = function.value(QLatin1String("arguments")).toString();
    delta.replaceName      = true;
    delta.replaceArguments = true;
    return delta;
}

void emitMessageParts(const QJsonObject& message, StreamEvents& out) {
    const QString reasoning = extractReasoningText(message);
    if (!reasoning.isEmpty()) out.append(StreamEvent::reasoningDelta(reasoning));

    const QJsonValue content = message.value(QLatin1String("content"));
    if (content.isString() && !content.toString().isEmpty()) {
        out.append(StreamEvent::textDelta(content.toString()));
    }

    const QJsonValue toolCalls = message.value(QLatin1String("tool_calls"));
    if (toolCalls.isArray()) {
        const QJsonArray calls = toolCalls.toArray();
        for (int i = 0; i < calls.size(); ++i) {
            out.append(StreamEvent::toolCallDelta(fullToolCall(i, calls[i].toObject())));
        }
    }
}

} // namespace

QByteArray ChatCompletionsAdapter::buildRequest(
    const QVector<MessageData>& messages,
    const RequestOptions&       options) const {
    QJsonObject body;
    body.insert(QStringLiteral("model"), options.model);
    body.insert(QStringLiteral("messages"), serializeMessagesForRequest(messages, options.capVision, options.resolveUrl));
    body.insert(QStringLiteral("temperature"), options.temperature);
    body.insert(QStringLiteral("stream"), options.stream);
    if (options.stream) {
        body.insert(QStringLiteral("stream_options"), QJsonObject{{QStringLiteral("include_usage"), true}});
    }
    if (options.capReasoning && !options.reasoningEffort.isEmpty()) {
        body.insert(QStringLiteral("reasoning_effort"), options.reasoningEffort);
    }

    const QJsonArray tools = withBuiltinTools(options.tools, options.builtinTools);
    if (!tools.isEmpty()) body.insert(QStringLiteral("tools"), tools);

    for (auto it = options.extraParams.constBegin(); it != options.extraParams.constEnd(); ++it) {
        body.insert(it.key(), it.value());
    }
    return QJsonDocument(body).toJson(QJsonDocument::Compact);
}

void ChatCompletionsAdapter::handleData(const QString& payload, StreamEvents& out) {
    if (payload.trimmed() == QLatin1String("[DONE]")) {
        markDone(out);
        return;
    }

    QJsonParseError     parseError{};
    const QJsonDocument document = QJsonDocument::fromJson(payload.toUtf8(), &parseError);
    if (parseError.error != QJsonParseError::NoError || !document.isObject()) return;

    const QJsonObject object = document.object();
    if (hasErrorObject(object)) {
        out.append(StreamEvent::error(errorMessageOf(object, QStringLiteral("API 请求失败"))));
        markDone(out);
        return;
    }

    const QJsonObject usage = object.value(QLatin1String("usage")).toObject();
    if (!usage.isEmpty()) out.append(StreamEvent::usageReport(parseUsageObject(usage)));

    const QJsonArray choices = object.value(QLatin1String("choices")).toArray();
    if (choices.isEmpty()) return;

    const QJsonObject choice = choices.first().toObject();
    QJsonObject       delta  = choice.value(QLatin1String("delta")).toObject();
    if (delta.isEmpty() && choice.contains(QLatin1String("message"))) {
        // A few gateways answer a "stream" request with one complete message.
        delta = choice.value(QLatin1String("message")).toObject();
    }

    const QString reasoning = extractReasoningText(delta);
    if (!reasoning.isEmpty()) out.append(StreamEvent::reasoningDelta(reasoning));

    const QJsonValue content = delta.value(QLatin1String("content"));
    if (content.isString() && !content.toString().isEmpty()) {
        out.append(StreamEvent::textDelta(content.toString()));
    }

    const QJsonValue toolCalls = delta.value(QLatin1String("tool_calls"));
    if (!toolCalls.isArray()) return;

    for (const auto& callValue : toolCalls.toArray()) {
        const QJsonObject call     = callValue.toObject();
        const QJsonObject function = call.value(QLatin1String("function")).toObject();

        ToolCallDelta toolDelta;
        toolDelta.index     = call.value(QLatin1String("index")).toInt(0);
        toolDelta.id        = call.value(QLatin1String("id")).toString();
        toolDelta.name      = function.value(QLatin1String("name")).toString();
        toolDelta.arguments = function.value(QLatin1String("arguments")).toString();
        out.append(StreamEvent::toolCallDelta(std::move(toolDelta)));
    }
}

StreamEvents ChatCompletionsAdapter::parseResponse(const QByteArray& body) const {
    StreamEvents out;

    QJsonParseError     parseError{};
    const QJsonDocument document = QJsonDocument::fromJson(body, &parseError);
    if (parseError.error != QJsonParseError::NoError || !document.isObject()) {
        out.append(StreamEvent::error(QStringLiteral("响应不是合法 JSON")));
        out.append(StreamEvent::done());
        return out;
    }

    const QJsonObject object = document.object();
    if (hasErrorObject(object)) {
        out.append(StreamEvent::error(errorMessageOf(object, QStringLiteral("API 请求失败"))));
        out.append(StreamEvent::done());
        return out;
    }

    const QJsonObject usage = object.value(QLatin1String("usage")).toObject();
    if (!usage.isEmpty()) out.append(StreamEvent::usageReport(parseUsageObject(usage)));

    const QJsonArray choices = object.value(QLatin1String("choices")).toArray();
    if (!choices.isEmpty()) {
        emitMessageParts(choices.first().toObject().value(QLatin1String("message")).toObject(), out);
    }

    out.append(StreamEvent::done());
    return out;
}

} // namespace mod::chatbot
