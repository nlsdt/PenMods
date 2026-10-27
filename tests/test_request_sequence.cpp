// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/context/HistoryTrimmer.h"
#include "chatbot/core/MessageJson.h"
#include "test_main.h"

#include <QJsonArray>
#include <QJsonObject>

using namespace mod::chatbot;

namespace {

MessageData msg(const char* role, const char* content) {
    MessageData m;
    m.role    = role;
    m.content = content;
    return m;
}

} // namespace

int main() {
    const QVector<MessageData> original = [] {
        QVector<MessageData> h;
        h.append(msg("user", "old"));
        h.append(msg("assistant", "old answer"));

        h.append(msg("user", "new"));
        MessageData assistant = msg("assistant", "");
        assistant.reasoning     = "reasoning-for-tool";
        assistant.toolCallsJson = R"([{"id":"c1","type":"function","function":{"name":"search","arguments":"{}"}}])";
        h.append(assistant);
        MessageData tool = msg("tool", "tool-result");
        tool.toolCallId = "c1";
        h.append(tool);
        h.append(msg("assistant", "final"));
        return h;
    }();

    QVector<MessageData> history = original;
    const int lastTurn = estimateTokens(history[2]) + estimateTokens(history[3]) + estimateTokens(history[4])
                       + estimateTokens(history[5]);
    trimHistoryToBudget(history, lastTurn + 1);

    CHECK_EQ(history.size(), 4);
    if (history.size() == 4) {
        CHECK_EQ(history[0].content, QString("new"));
        CHECK_EQ(history[1].toolCallsJson, original[3].toolCallsJson);
        CHECK_EQ(history[2].role, QString("tool"));
        CHECK_EQ(history[2].toolCallId, QString("c1"));
    }

    QJsonArray request;
    for (const auto& message : original) {
        request.append(messageToRequestJson(message, false));
    }
    CHECK_EQ(request.size(), 6);
    CHECK_EQ(request[3].toObject().value("reasoning_content").toString(), QString("reasoning-for-tool"));
    CHECK(request[3].toObject().value("tool_calls").isArray());
    CHECK_EQ(request[4].toObject().value("role").toString(), QString("tool"));
    CHECK_EQ(request[4].toObject().value("tool_call_id").toString(), QString("c1"));

    return testSummary("request_sequence");
}
