// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/context/ContextAssembler.h"
#include "test_main.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QString>

using namespace mod::chatbot;

namespace {

MessageData make(const char* role, const char* content) {
    MessageData msg;
    msg.role    = QString::fromUtf8(role);
    msg.content = QString::fromUtf8(content);
    return msg;
}

MessageData assistantWithCalls(const QString& callsJson, const QString& content = QString()) {
    MessageData msg;
    msg.role          = QStringLiteral("assistant");
    msg.content       = content;
    msg.toolCallsJson = callsJson;
    return msg;
}

MessageData toolResult(const char* id, const char* content) {
    MessageData msg;
    msg.role       = QStringLiteral("tool");
    msg.toolCallId = QString::fromUtf8(id);
    msg.content    = QString::fromUtf8(content);
    return msg;
}

QStringList rolesOf(const QVector<MessageData>& messages) {
    QStringList roles;
    for (const auto& message : messages) roles.append(message.role);
    return roles;
}

} // namespace

int main() {
    // ------------------------------------------------------- system + user
    {
        QVector<MessageData> history;
        history.append(make("user", "first"));
        history.append(make("assistant", "first answer"));
        history.append(make("assistant", "")); // aborted placeholder

        const AssembledContext context =
            ContextAssembler::assemble(history, make("user", "second"), ContextOptions{QStringLiteral("SYS"), 0, 0});

        CHECK_EQ(context.messages.size(), 4);
        CHECK(context.messages.first().role == QStringLiteral("system"));
        CHECK(context.messages.first().content == QStringLiteral("SYS"));
        CHECK(context.messages.last().role == QStringLiteral("user"));
        CHECK(context.messages.last().content == QStringLiteral("second"));
        CHECK(!context.messages.last().messageId.isEmpty());
        // The empty assistant placeholder was dropped.
        CHECK_EQ(rolesOf(context.messages).count(QStringLiteral("assistant")), 1);
        CHECK(context.estimatedTokens > 0);
    }

    // ---------------------------------------------------- tool normalization
    {
        QVector<MessageData> history;
        history.append(make("user", "run"));
        history.append(assistantWithCalls(
            R"([{"id":"c1","type":"function","function":{"name":"a","arguments":"{}"}},)"
            R"({"id":"c1","type":"function","function":{"name":"dup","arguments":"{}"}},)"
            R"({"id":"","type":"function","function":{"name":"noid","arguments":"{}"}},)"
            R"({"id":"c2","type":"function","function":{"name":"b","arguments":"{}"}}])"));
        history.append(toolResult("c1", "one"));
        history.append(toolResult("orphan", "ignored"));
        history.append(toolResult("c1", "duplicate result ignored"));

        QVector<MessageData> messages = history;
        ContextAssembler::normalizeToolSequence(messages);

        CHECK_EQ(messages.size(), 4); // user, assistant, tool c1, tool c2
        if (messages.size() == 4) {
            CHECK(messages[1].role == QStringLiteral("assistant"));
            const QJsonArray calls = QJsonDocument::fromJson(messages[1].toolCallsJson.toUtf8()).array();
            CHECK_EQ(calls.size(), 2);
            CHECK(messages[2].toolCallId == QStringLiteral("c1"));
            CHECK(messages[2].content == QStringLiteral("one"));
            CHECK(messages[3].toolCallId == QStringLiteral("c2"));
            CHECK(messages[3].content == pendingToolResultText());
        }
    }

    // ------------------------------------------- invalid calls become plain
    {
        QVector<MessageData> messages;
        messages.append(make("user", "x"));
        messages.append(assistantWithCalls(R"([{"id":"","function":{"name":"a"}}])", "visible"));
        ContextAssembler::normalizeToolSequence(messages);
        CHECK_EQ(messages.size(), 2);
        CHECK(messages[1].toolCallsJson.isEmpty());
        CHECK(messages[1].content == QStringLiteral("visible"));
    }

    // ------------------------------------------------------- budget trimming
    {
        QVector<MessageData> history;
        for (int turn = 0; turn < 6; ++turn) {
            history.append(make("user", "old question with some words to spend tokens"));
            history.append(make("assistant", "old answer with some words to spend tokens"));
        }

        ContextOptions options{QStringLiteral("SYS"), 200, 0};
        const AssembledContext context =
            ContextAssembler::assemble(history, make("user", "new question"), options);

        // Oldest turns are dropped, the system prompt and the new user message stay.
        CHECK(context.droppedMessages > 0);
        CHECK(context.messages.first().role == QStringLiteral("system"));
        CHECK(context.messages.last().content == QStringLiteral("new question"));
        CHECK(context.estimatedTokens <= 200);
        // Whole turns only: every user message still has its answer behind it.
        const QStringList roles = rolesOf(context.messages);
        CHECK_EQ(roles.first(), QStringLiteral("system"));
        CHECK_EQ(roles.count(QStringLiteral("user")), roles.count(QStringLiteral("assistant")) + 1);
    }

    // ----------------------------------------- budget never drops last turn
    {
        QVector<MessageData> history;
        history.append(make("user", "previous"));
        history.append(make("assistant", "answer"));

        const AssembledContext context =
            ContextAssembler::assemble(history, make("user", "now"), ContextOptions{QStringLiteral("S"), 10, 0});

        CHECK(context.messages.first().role == QStringLiteral("system"));
        CHECK_EQ(context.messages.size(), 4);
        CHECK(context.messages.last().content == QStringLiteral("now"));
        CHECK(context.droppedMessages >= 0);
    }

    // ------------------------------------------------------- multimodal user
    {
        MessageData user;
        user.role = QStringLiteral("user");
        MessagePart text;
        text.type = QStringLiteral("text");
        text.text = QStringLiteral("describe");
        MessagePart image;
        image.type = QStringLiteral("image_url");
        image.url  = QStringLiteral("data:image/png;base64,AAAA");
        user.parts.append(text);
        user.parts.append(image);

        const AssembledContext context = ContextAssembler::assemble({}, user);
        CHECK_EQ(context.messages.size(), 1);
        CHECK(context.messages.first().parts.size() == 2);
    }

    return testSummary("context");
}
