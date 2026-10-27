// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "ContextAssembler.h"

#include "HistoryTrimmer.h"

#include <QHash>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSet>
#include <QStringList>
#include <QUuid>

#include <utility>

namespace mod::chatbot {

namespace {

// An assistant message with no visible content is a placeholder from an aborted
// stream; sending it confuses strict providers.
bool isEmptyAssistant(const MessageData& message) {
    return message.role == QLatin1String("assistant") && message.content.isEmpty()
           && message.toolCallsJson.isEmpty() && message.parts.isEmpty();
}

QString normalizeId(const QString& id) {
    return id.trimmed();
}

} // namespace

QString pendingToolResultText() {
    return QStringLiteral("该工具调用已被用户取消或未完成，请直接根据已有信息继续回答，不要重复调用该工具。");
}

void ContextAssembler::normalizeToolSequence(QVector<MessageData>& messages) {
    QVector<MessageData> normalized;
    normalized.reserve(messages.size());

    for (int index = 0; index < messages.size(); ++index) {
        const MessageData& message = messages.at(index);

        // Tool results are recreated below, attached to their call.
        if (message.role == QLatin1String("tool")) continue;

        if (message.role != QLatin1String("assistant") || message.toolCallsJson.isEmpty()) {
            normalized.append(message);
            continue;
        }

        const QJsonDocument callDocument = QJsonDocument::fromJson(message.toolCallsJson.toUtf8());
        const QJsonArray    calls        = callDocument.array();

        QJsonArray    validCalls;
        QStringList   pendingIds;
        QSet<QString> seenIds;
        for (const auto& callValue : calls) {
            const QJsonObject call = callValue.toObject();
            const QString     id   = normalizeId(call.value(QStringLiteral("id")).toString());
            if (id.isEmpty() || seenIds.contains(id)) continue;
            seenIds.insert(id);
            validCalls.append(call);
            pendingIds.append(id);
        }

        MessageData assistant = message;
        if (validCalls.isEmpty()) {
            assistant.toolCallsJson.clear();
            if (isEmptyAssistant(assistant)) continue;
            normalized.append(std::move(assistant));
            continue;
        }
        if (validCalls.size() != calls.size()) {
            assistant.toolCallsJson =
                QString::fromUtf8(QJsonDocument(validCalls).toJson(QJsonDocument::Compact));
        }
        normalized.append(std::move(assistant));

        QHash<QString, QString> results;
        while (index + 1 < messages.size() && messages.at(index + 1).role == QLatin1String("tool")) {
            const MessageData& tool = messages.at(++index);
            const QString      id   = normalizeId(tool.toolCallId);
            if (id.isEmpty() || results.contains(id)) continue;
            results.insert(id, tool.content);
        }

        for (const QString& id : pendingIds) {
            MessageData tool;
            tool.role       = QStringLiteral("tool");
            tool.toolCallId = id;
            tool.content    = results.contains(id) ? results.value(id) : pendingToolResultText();
            normalized.append(std::move(tool));
        }
    }

    messages = std::move(normalized);
}

AssembledContext ContextAssembler::assembleContinuation(
    const QVector<MessageData>& history,
    const ContextOptions&       options) {
    AssembledContext result;

    QVector<MessageData> messages;
    messages.reserve(history.size() + 1);
    for (const auto& message : history) {
        if (isEmptyAssistant(message)) continue;
        messages.append(message);
    }

    const int beforeTrim = messages.size();
    if (options.maxContextTokens > 0) {
        int budget = options.maxContextTokens - options.reserveOutputTokens;
        if (!options.systemPrompt.isEmpty()) {
            MessageData system;
            system.role    = QStringLiteral("system");
            system.content = options.systemPrompt;
            budget -= estimateTokens(system);
        }
        trimHistoryToBudget(messages, budget);
    }
    result.droppedMessages = beforeTrim - messages.size();

    if (!options.systemPrompt.isEmpty()) {
        MessageData system;
        system.role    = QStringLiteral("system");
        system.content = options.systemPrompt;
        messages.prepend(std::move(system));
    }

    normalizeToolSequence(messages);
    result.estimatedTokens = estimateTokens(messages);
    result.messages        = std::move(messages);
    return result;
}

AssembledContext ContextAssembler::assemble(
    const QVector<MessageData>& history,
    const MessageData&          userMessage,
    const ContextOptions&       options) {
    AssembledContext result;

    QVector<MessageData> messages;
    messages.reserve(history.size() + 2);

    for (const auto& message : history) {
        if (isEmptyAssistant(message)) continue;
        messages.append(message);
    }

    MessageData user = userMessage;
    if (user.messageId.isEmpty()) {
        user.messageId = QUuid::createUuid().toString(QUuid::WithoutBraces);
    }
    if (user.role.isEmpty()) user.role = QStringLiteral("user");

    const int beforeTrim = messages.size();
    if (options.maxContextTokens > 0) {
        int budget = options.maxContextTokens - options.reserveOutputTokens;
        budget -= estimateTokens(user);
        if (!options.systemPrompt.isEmpty()) {
            MessageData system;
            system.role    = QStringLiteral("system");
            system.content = options.systemPrompt;
            budget -= estimateTokens(system);
        }
        trimHistoryToBudget(messages, budget);
    }
    result.droppedMessages = beforeTrim - messages.size();

    if (!options.systemPrompt.isEmpty()) {
        MessageData system;
        system.role    = QStringLiteral("system");
        system.content = options.systemPrompt;
        messages.prepend(std::move(system));
    }
    messages.append(std::move(user));

    normalizeToolSequence(messages);

    result.estimatedTokens = estimateTokens(messages);
    result.messages        = std::move(messages);
    return result;
}

} // namespace mod::chatbot
