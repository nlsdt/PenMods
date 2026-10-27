// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/context/HistoryTrimmer.h"
#include "test_main.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSet>
#include <QString>

using mod::chatbot::MessageData;

namespace {

MessageData makeUser(int index) {
    MessageData message;
    message.role    = QStringLiteral("user");
    message.content = QStringLiteral("user %1").arg(index);
    return message;
}

MessageData makeAssistant(int index) {
    MessageData message;
    message.role      = QStringLiteral("assistant");
    message.reasoning = QStringLiteral("reasoning %1").arg(index);
    message.toolCallsJson =
        QStringLiteral(R"([{"id":"call-%1","type":"function","function":{"name":"search","arguments":"{}"}}])")
            .arg(index);
    return message;
}

MessageData makeTool(int index) {
    MessageData message;
    message.role       = QStringLiteral("tool");
    message.toolCallId = QStringLiteral("call-%1").arg(index);
    message.content    = QStringLiteral("result %1").arg(index);
    return message;
}

QVector<MessageData> makeHistory(int turns) {
    QVector<MessageData> messages;
    for (int i = 0; i < turns; ++i) {
        messages.append(makeUser(i));
        messages.append(makeAssistant(i));
        messages.append(makeTool(i));
    }
    return messages;
}

QSet<QString> toolCallIds(const MessageData& message) {
    QSet<QString> ids;
    const QJsonArray calls = QJsonDocument::fromJson(message.toolCallsJson.toUtf8()).array();
    for (const auto& value : calls) ids.insert(value.toObject().value(QStringLiteral("id")).toString());
    return ids;
}

// 整轮裁剪后必须仍然：以 user 开头、tool_calls 与 tool 结果成对、没有孤立 tool。
bool validSequence(const QVector<MessageData>& messages) {
    if (messages.isEmpty()) return true;
    if (messages.first().role != QStringLiteral("user")) return false;

    QSet<QString> pending;
    for (const auto& message : messages) {
        if (message.role == QStringLiteral("user")) {
            if (!pending.isEmpty()) return false;
        } else if (message.role == QStringLiteral("assistant")) {
            if (!pending.isEmpty()) return false;
            if (!message.toolCallsJson.isEmpty()) {
                pending = toolCallIds(message);
                if (pending.isEmpty()) return false;
            }
        } else if (message.role == QStringLiteral("tool")) {
            if (!pending.contains(message.toolCallId)) return false;
            pending.remove(message.toolCallId);
        } else {
            return false;
        }
    }
    return pending.isEmpty();
}

void testNoTrimUnderBudget() {
    auto messages = makeHistory(40);
    CHECK_EQ(messages.size(), 120);

    mod::chatbot::trimHistoryToBudget(messages, 1000000);
    CHECK_EQ(messages.size(), 120);
    CHECK(validSequence(messages));
}

void testWholeTurnTrim() {
    auto messages = makeHistory(40);
    mod::chatbot::trimHistoryToBudget(messages, 200);

    CHECK(!messages.isEmpty());
    CHECK(messages.size() < 120);
    CHECK(messages.first().role == QStringLiteral("user"));
    CHECK(validSequence(messages));

    for (const auto& message : messages) {
        if (message.role != QStringLiteral("assistant") || message.toolCallsJson.isEmpty()) continue;
        CHECK(!message.reasoning.isEmpty());
    }
}

void testSingleTurnNeverSplit() {
    QVector<MessageData> messages;
    messages.append(makeUser(0));
    MessageData assistant = makeAssistant(0);
    assistant.content     = QString(100000, QLatin1Char('x'));
    messages.append(assistant);
    messages.append(makeTool(0));

    mod::chatbot::trimHistoryToBudget(messages, 10);
    CHECK_EQ(messages.size(), 3);
    CHECK(validSequence(messages));
}

void testTokenEstimate() {
    CHECK_EQ(mod::chatbot::estimateTokens(QString()), 0);
    CHECK(mod::chatbot::estimateTokens(QStringLiteral("中文")) > mod::chatbot::estimateTokens(QStringLiteral("ab")));
    CHECK(mod::chatbot::estimateTokens(QString(4000, QLatin1Char('x'))) > 900);
}

void testZeroBudgetNoop() {
    auto messages = makeHistory(5);
    mod::chatbot::trimHistoryToBudget(messages, 0);
    CHECK_EQ(messages.size(), 15);
}

} // namespace

int main() {
    testNoTrimUnderBudget();
    testWholeTurnTrim();
    testSingleTurnNeverSplit();
    testTokenEstimate();
    testZeroBudgetNoop();
    return testSummary("test_history_trim");
}
