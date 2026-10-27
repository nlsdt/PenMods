// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/session/SessionRepository.h"
#include "test_main.h"

#include <QString>

#include <string>
#include <vector>

using namespace mod::chatbot;

namespace {

MessageData makeMessage(const char* id, const char* role, const char* content) {
    MessageData msg;
    msg.messageId = QString::fromUtf8(id);
    msg.role      = QString::fromUtf8(role);
    msg.content   = QString::fromUtf8(content);
    return msg;
}

} // namespace

int main() {
    auto opened = SessionRepository::open(":memory:");
    CHECK(opened.has_value());
    if (!opened) {
        return testSummary("session_repository");
    }
    auto& repo = *opened;

    CHECK(!repo->createSession(QString(), "x").has_value());
    CHECK(repo->createSession("s1", "Title", 1000).has_value());
    CHECK(repo->setActiveSession("s1").has_value());

    MessageData assistant = makeMessage("m2", "assistant", "answer");
    assistant.reasoning     = "think";
    assistant.toolCallsJson = R"([{"id":"c1","type":"function","function":{"name":"search","arguments":"{}"}}])";
    assistant.toolStates.append(QVariantMap{{"state", "done"}, {"text", "ok"}});

    MessageData tool = makeMessage("m3", "tool", "result");
    tool.toolCallId = "c1";

    // Event-level append across three calls (user, assistant, tool).
    CHECK(repo->appendMessages("s1", {makeMessage("m1", "user", "hi")}, 1001).has_value());
    CHECK(repo->appendMessages("s1", {assistant}, 1002).has_value());
    CHECK(repo->appendMessages("s1", {tool}, 1003).has_value());

    // System messages are not part of the persisted log.
    CHECK(!repo->appendMessages("s1", {makeMessage("m9", "system", "prompt")}, 1004).has_value());

    auto loaded = repo->load();
    CHECK(loaded.has_value());
    if (!loaded) {
        return testSummary("session_repository");
    }
    CHECK_EQ(loaded->sessions.size(), std::size_t{1});
    CHECK_EQ(loaded->activeSessionId, QString("s1"));
    if (!loaded->sessions.empty()) {
        const auto& restored = loaded->sessions.front();
        CHECK_EQ(restored.id, QString("s1"));
        CHECK_EQ(restored.title, QString("Title"));
        CHECK_EQ(restored.messages.size(), 3);
        if (restored.messages.size() == 3) {
            CHECK_EQ(restored.messages[0].messageId, QString("m1"));
            CHECK_EQ(restored.messages[1].reasoning, QString("think"));
            CHECK_EQ(restored.messages[1].toolCallsJson, assistant.toolCallsJson);
            CHECK_EQ(restored.messages[1].toolStates.size(), 1);
            CHECK_EQ(restored.messages[2].toolCallId, QString("c1"));
            CHECK_EQ(restored.messages[2].content, QString("result"));
        }
    }

    CHECK(repo->renameSession("s1", "Renamed", 2000).has_value());

    // Tail rewrite: keep the user message, replace everything after it.
    MessageData edited = makeMessage("m2b", "assistant", "edited answer");
    CHECK(repo->syncTail("s1", {makeMessage("m1", "user", "hi"), edited}, 1, 2001).has_value());

    auto rewritten = repo->load();
    CHECK(rewritten.has_value());
    if (rewritten && !rewritten->sessions.empty()) {
        const auto& restored = rewritten->sessions.front();
        CHECK_EQ(restored.title, QString("Renamed"));
        CHECK_EQ(restored.messages.size(), 2);
        if (restored.messages.size() == 2) {
            CHECK_EQ(restored.messages[1].messageId, QString("m2b"));
            CHECK_EQ(restored.messages[1].content, QString("edited answer"));
        }
    }

    // Pure truncation removes the tail without appending anything.
    CHECK(repo->syncTail("s1", {makeMessage("m1", "user", "hi")}, 1, 2002).has_value());
    auto truncated = repo->load();
    if (truncated && !truncated->sessions.empty()) {
        CHECK_EQ(truncated->sessions.front().messages.size(), 1);
    }

    CHECK(repo->clearMessages("s1", 2003).has_value());
    auto cleared = repo->load();
    if (cleared && !cleared->sessions.empty()) {
        CHECK_EQ(cleared->sessions.front().messages.size(), 0);
    }

    CHECK(!repo->appendMessages("missing", {makeMessage("m4", "user", "x")}).has_value());
    CHECK(!repo->createSession(QString(), "x").has_value());
    CHECK(!repo->syncTail("s1", {}, -1).has_value());

    return testSummary("session_repository");
}
