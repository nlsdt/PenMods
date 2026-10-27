// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "ResponsesAdapter.h"

#include "ProtocolCommon.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

namespace mod::chatbot {

namespace {

bool isServerToolItem(const QString& type) {
    return type.endsWith(QLatin1String("_call")) && type != QLatin1String("function_call");
}

QJsonArray toResponsesInput(const QJsonArray& messages) {
    QJsonArray input;
    for (const auto& value : messages) {
        const QJsonObject message = value.toObject();
        const QString     role    = message.value(QLatin1String("role")).toString();

        if (role == QLatin1String("tool")) {
            input.append(
                QJsonObject{
                    {QStringLiteral("type"), QJsonValue(QStringLiteral("function_call_output"))                    },
                    {QStringLiteral("call_id"), message.value(QLatin1String("tool_call_id"))                       },
                    {QStringLiteral("output"), message.value(QLatin1String("content"))                              }
            }
            );
            continue;
        }

        QJsonValue       content;
        const QJsonValue contentValue = message.value(QLatin1String("content"));
        if (contentValue.isString()) {
            content = contentValue;
        } else if (contentValue.isArray()) {
            QJsonArray responsesContent;
            bool       hasUnsupportedMedia = false;
            for (const auto& partValue : contentValue.toArray()) {
                const QJsonObject part     = partValue.toObject();
                const QString     partType = part.value(QLatin1String("type")).toString();
                if (partType == QLatin1String("text")) {
                    const QString text = part.value(QLatin1String("text")).toString();
                    if (!text.isEmpty()) {
                        responsesContent.append(
                            QJsonObject{
                                {QStringLiteral("type"), QStringLiteral("input_text")},
                                {QStringLiteral("text"), text                        }
                        }
                        );
                    }
                } else if (partType == QLatin1String("image_url")) {
                    const QString imageUrl = part.value(QLatin1String("image_url")).toObject().value(QLatin1String("url")).toString();
                    if (!imageUrl.isEmpty()) {
                        responsesContent.append(
                            QJsonObject{
                                {QStringLiteral("type"), QStringLiteral("input_image")},
                                {QStringLiteral("image_url"), imageUrl                 }
                        }
                        );
                    }
                } else {
                    hasUnsupportedMedia = true;
                }
            }
            if (responsesContent.isEmpty() && hasUnsupportedMedia) {
                responsesContent.append(
                    QJsonObject{
                        {QStringLiteral("type"), QStringLiteral("input_text")            },
                        {QStringLiteral("text"), QStringLiteral("[不支持的媒体输入]")     }
                }
                );
            }
            content = responsesContent;
        }

        if ((content.isString() && !content.toString().isEmpty())
            || (content.isArray() && !content.toArray().isEmpty())) {
            input.append(
                QJsonObject{
                    {QStringLiteral("type"), QStringLiteral("message")},
                    {QStringLiteral("role"), role                     },
                    {QStringLiteral("content"), content               }
            }
            );
        }

        const QJsonValue toolCalls = message.value(QLatin1String("tool_calls"));
        if (toolCalls.isArray()) {
            for (const auto& toolValue : toolCalls.toArray()) {
                const QJsonObject tool     = toolValue.toObject();
                const QJsonObject function = tool.value(QLatin1String("function")).toObject();
                input.append(
                    QJsonObject{
                        {QStringLiteral("type"), QJsonValue(QStringLiteral("function_call"))                        },
                        {QStringLiteral("call_id"), tool.value(QLatin1String("id"))                                 },
                        {QStringLiteral("name"), function.value(QLatin1String("name"))                              },
                        {QStringLiteral("arguments"), function.value(QLatin1String("arguments"))                    }
                }
                );
            }
        }
    }
    return input;
}

QJsonArray flattenTools(const QJsonArray& tools, const QJsonArray& builtinTools) {
    QJsonArray flattened;
    for (const auto& value : tools) {
        const QJsonObject tool     = value.toObject();
        const QJsonObject function = tool.value(QLatin1String("function")).toObject();
        QJsonObject       flat{{QStringLiteral("type"), QStringLiteral("function")}};
        for (auto it = function.constBegin(); it != function.constEnd(); ++it) flat.insert(it.key(), it.value());
        if (tool.contains(QLatin1String("description")) && !flat.contains(QLatin1String("description"))) {
            flat.insert(QStringLiteral("description"), tool.value(QLatin1String("description")));
        }
        flattened.append(flat);
    }
    for (const auto& value : builtinTools) flattened.append(value);
    return flattened;
}

QString outputText(const QJsonArray& output) {
    QString text;
    for (const auto& itemValue : output) {
        const QJsonObject item = itemValue.toObject();
        if (item.value(QLatin1String("type")).toString() != QLatin1String("message")) continue;
        for (const auto& contentValue : item.value(QLatin1String("content")).toArray()) {
            const QJsonObject content = contentValue.toObject();
            if (content.value(QLatin1String("type")).toString() == QLatin1String("output_text")) {
                text += content.value(QLatin1String("text")).toString();
            }
        }
    }
    return text;
}

QString outputReasoning(const QJsonArray& output) {
    QString reasoning;
    for (const auto& itemValue : output) {
        const QJsonObject item = itemValue.toObject();
        if (item.value(QLatin1String("type")).toString() != QLatin1String("reasoning")) continue;

        QString summary;
        for (const auto& summaryValue : item.value(QLatin1String("summary")).toArray()) {
            const QJsonObject summaryObject = summaryValue.toObject();
            if (summaryObject.value(QLatin1String("type")).toString() == QLatin1String("summary_text")) {
                summary += summaryObject.value(QLatin1String("text")).toString();
            }
        }

        QString content;
        for (const auto& contentValue : item.value(QLatin1String("content")).toArray()) {
            const QJsonObject contentObject = contentValue.toObject();
            const QString     contentType   = contentObject.value(QLatin1String("type")).toString();
            if (contentType == QLatin1String("reasoning_text") || contentType == QLatin1String("text")
                || contentType == QLatin1String("summary_text")) {
                content += contentObject.value(QLatin1String("text")).toString();
            }
        }
        reasoning += content.isEmpty() ? summary : content;
    }
    return reasoning;
}

} // namespace

QByteArray ResponsesAdapter::buildRequest(
    const QVector<MessageData>& messages,
    const RequestOptions&       options) const {
    QJsonObject body;
    body.insert(QStringLiteral("model"), options.model);
    body.insert(
        QStringLiteral("input"),
        toResponsesInput(serializeMessagesForRequest(messages, options.capVision, options.resolveUrl)));
    body.insert(QStringLiteral("temperature"), options.temperature);
    body.insert(QStringLiteral("stream"), options.stream);

    if (options.capReasoning) {
        QJsonObject reasoning{{QStringLiteral("summary"), QStringLiteral("auto")}};
        if (!options.reasoningEffort.isEmpty()) {
            reasoning.insert(QStringLiteral("effort"), options.reasoningEffort);
        }
        body.insert(QStringLiteral("reasoning"), reasoning);
    }

    const QJsonArray tools = flattenTools(options.tools, options.builtinTools);
    if (!tools.isEmpty()) body.insert(QStringLiteral("tools"), tools);

    for (auto it = options.extraParams.constBegin(); it != options.extraParams.constEnd(); ++it) {
        body.insert(it.key(), it.value());
    }
    return QJsonDocument(body).toJson(QJsonDocument::Compact);
}

void ResponsesAdapter::reset() {
    ProtocolAdapter::reset();
    m_itemIndexes.clear();
    m_nextToolIndex = 0;
    m_textSeen      = false;
    m_reasoningSeen = false;
    m_toolSeen      = false;
}

int ResponsesAdapter::indexFor(const QString& itemId) {
    const auto it = m_itemIndexes.constFind(itemId);
    if (it != m_itemIndexes.constEnd()) return it.value();
    const int index = m_nextToolIndex++;
    m_itemIndexes.insert(itemId, index);
    return index;
}

void ResponsesAdapter::emitOutput(const QJsonArray& output, StreamEvents& out, bool fullPayload) {
    if (!m_reasoningSeen) {
        const QString reasoning = outputReasoning(output);
        if (!reasoning.isEmpty()) {
            out.append(StreamEvent::reasoningDelta(reasoning));
            m_reasoningSeen = true;
        }
    }
    if (!m_textSeen) {
        const QString text = outputText(output);
        if (!text.isEmpty()) {
            out.append(StreamEvent::textDelta(text));
            m_textSeen = true;
        }
    }

    for (const auto& itemValue : output) {
        const QJsonObject item = itemValue.toObject();
        const QString     type = item.value(QLatin1String("type")).toString();

        if (type == QLatin1String("function_call")) {
            const QString id = item.value(QLatin1String("call_id")).toString();
            if ((fullPayload || !m_toolSeen) && !id.isEmpty()) {
                ToolCallDelta delta;
                delta.index            = indexFor(item.value(QLatin1String("id")).toString(id));
                delta.id               = id;
                delta.name             = item.value(QLatin1String("name")).toString();
                delta.arguments        = item.value(QLatin1String("arguments")).toString();
                delta.replaceName      = true;
                delta.replaceArguments = true;
                out.append(StreamEvent::toolCallDelta(std::move(delta)));
                m_toolSeen = true;
            }
        } else if (type == QLatin1String("image_generation_call")) {
            const QString result = item.value(QLatin1String("result")).toString();
            if (!result.isEmpty()) out.append(StreamEvent::image(result));
        }
    }
}

void ResponsesAdapter::handleData(const QString& payload, StreamEvents& out) {
    QJsonParseError     parseError{};
    const QJsonDocument document = QJsonDocument::fromJson(payload.toUtf8(), &parseError);
    if (parseError.error != QJsonParseError::NoError || !document.isObject()) return;

    const QJsonObject object    = document.object();
    const QString     eventType = object.value(QLatin1String("type")).toString();

    if (eventType == QLatin1String("error")) {
        out.append(StreamEvent::error(errorMessageOf(object, QStringLiteral("API 请求失败"))));
        markDone(out);
        return;
    }

    if (eventType == QLatin1String("response.output_text.delta")) {
        const QString text = object.value(QLatin1String("delta")).toString();
        if (!text.isEmpty()) {
            m_textSeen = true;
            out.append(StreamEvent::textDelta(text));
        }
        return;
    }

    if (eventType == QLatin1String("response.reasoning_summary_text.delta")
        || eventType == QLatin1String("response.reasoning_text.delta")) {
        const QString reasoning = object.value(QLatin1String("delta")).toString();
        if (!reasoning.isEmpty()) {
            m_reasoningSeen = true;
            out.append(StreamEvent::reasoningDelta(reasoning));
        }
        return;
    }

    if (eventType == QLatin1String("response.reasoning_summary_text.done")
        || eventType == QLatin1String("response.reasoning_text.done")) {
        // Some servers only push the final text; use it when no delta arrived.
        if (!m_reasoningSeen) {
            const QString reasoning = object.value(QLatin1String("text")).toString();
            if (!reasoning.isEmpty()) {
                m_reasoningSeen = true;
                out.append(StreamEvent::reasoningDelta(reasoning));
            }
        }
        return;
    }

    if (eventType == QLatin1String("response.function_call_arguments.delta")) {
        const QString callId = object.value(QLatin1String("item_id")).toString(
            object.value(QLatin1String("call_id")).toString());
        if (callId.isEmpty()) return;
        ToolCallDelta delta;
        delta.index     = indexFor(callId);
        delta.id        = callId;
        delta.arguments = object.value(QLatin1String("delta")).toString();
        m_toolSeen      = true;
        out.append(StreamEvent::toolCallDelta(std::move(delta)));
        return;
    }

    if (eventType == QLatin1String("response.output_item.added")
        || eventType == QLatin1String("response.output_item.done")) {
        const QJsonObject item     = object.value(QLatin1String("item")).toObject();
        const QString     itemType = item.value(QLatin1String("type")).toString();

        if (itemType == QLatin1String("function_call")) {
            ToolCallDelta delta;
            delta.index = indexFor(item.value(QLatin1String("id")).toString());
            delta.id    = item.value(QLatin1String("call_id")).toString();
            delta.name  = item.value(QLatin1String("name")).toString();
            delta.arguments        = item.value(QLatin1String("arguments")).toString();
            delta.replaceName      = true;
            delta.replaceArguments = true;
            m_toolSeen             = true;
            out.append(StreamEvent::toolCallDelta(std::move(delta)));
        } else if (isServerToolItem(itemType)) {
            const bool failed = item.value(QLatin1String("status")).toString() == QLatin1String("failed");
            out.append(StreamEvent::toolStatus(
                itemType,
                eventType.endsWith(QLatin1String(".added")) ? QStringLiteral("running")
                                                           : (failed ? QStringLiteral("error") : QStringLiteral("done"))));
        }
        return;
    }

    if (eventType.startsWith(QLatin1String("response.")) && eventType.contains(QLatin1String("_call."))) {
        const QString toolName = eventType.section(QLatin1Char('.'), 1, 1);
        if (eventType.endsWith(QLatin1String(".in_progress"))) {
            out.append(StreamEvent::toolStatus(toolName, QStringLiteral("running")));
        } else if (eventType.endsWith(QLatin1String(".completed")) || eventType.endsWith(QLatin1String(".done"))) {
            out.append(StreamEvent::toolStatus(toolName, QStringLiteral("done")));
        } else if (eventType.endsWith(QLatin1String(".failed"))) {
            out.append(StreamEvent::toolStatus(toolName, QStringLiteral("error")));
        }
        return;
    }

    if (eventType == QLatin1String("response.failed") || eventType == QLatin1String("response.incomplete")) {
        const QJsonObject response = object.value(QLatin1String("response")).toObject();
        const QString     detail   = errorMessageOf(response, QStringLiteral("响应未完成"));
        out.append(StreamEvent::error(QStringLiteral("API 请求失败\n") + detail));
        markDone(out);
        return;
    }

    if (eventType == QLatin1String("response.completed")) {
        const QJsonObject response = object.value(QLatin1String("response")).toObject();
        QJsonObject       usage    = object.value(QLatin1String("usage")).toObject();
        if (usage.isEmpty()) usage = response.value(QLatin1String("usage")).toObject();
        if (!usage.isEmpty()) out.append(StreamEvent::usageReport(parseUsageObject(usage)));

        if (response.value(QLatin1String("status")).toString() != QLatin1String("completed")) {
            const QString detail = errorMessageOf(response, QStringLiteral("响应未完成"));
            out.append(StreamEvent::error(QStringLiteral("API 请求失败\n") + detail));
            markDone(out);
            return;
        }

        emitOutput(response.value(QLatin1String("output")).toArray(), out, false);
        markDone(out);
        return;
    }
}

StreamEvents ResponsesAdapter::parseResponse(const QByteArray& body) const {
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

    const QJsonArray output = object.value(QLatin1String("output")).toArray();

    const QString reasoning = outputReasoning(output);
    if (!reasoning.isEmpty()) out.append(StreamEvent::reasoningDelta(reasoning));

    const QString text = outputText(output);
    if (!text.isEmpty()) out.append(StreamEvent::textDelta(text));

    int toolIndex = 0;
    for (const auto& itemValue : output) {
        const QJsonObject item = itemValue.toObject();
        const QString     type = item.value(QLatin1String("type")).toString();
        if (type == QLatin1String("function_call")) {
            ToolCallDelta delta;
            delta.index            = toolIndex++;
            delta.id               = item.value(QLatin1String("call_id")).toString();
            delta.name             = item.value(QLatin1String("name")).toString();
            delta.arguments        = item.value(QLatin1String("arguments")).toString();
            delta.replaceName      = true;
            delta.replaceArguments = true;
            out.append(StreamEvent::toolCallDelta(std::move(delta)));
        } else if (type == QLatin1String("image_generation_call")) {
            const QString result = item.value(QLatin1String("result")).toString();
            if (!result.isEmpty()) out.append(StreamEvent::image(result));
        }
    }

    out.append(StreamEvent::done());
    return out;
}

} // namespace mod::chatbot
