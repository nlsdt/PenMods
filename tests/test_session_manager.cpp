// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/session/SessionManager.h"
#include "test_main.h"

#include <QDir>
#include <QString>
#include <QTemporaryDir>

#include <memory>

using namespace mod::chatbot;

namespace {

MessageData makeMessage(const char* role, const char* content) {
    MessageData msg;
    msg.role    = QString::fromUtf8(role);
    msg.content = QString::fromUtf8(content);
    return msg;
}

} // namespace

int main() {
    QTemporaryDir dir;
    CHECK(dir.isValid());
    if (!dir.isValid()) {
        return testSummary("session_manager");
    }
    const QString dbPath = QDir(dir.path()).filePath("sessions.db");

    auto opened = SessionManager::open(dbPath);
    CHECK(opened.has_value());
    if (!opened) {
        return testSummary("session_manager");
    }
    auto& manager = *opened;

    // A fresh store always has one active conversation.
    CHECK_EQ(manager->sessions().size(), 1);
    const QString firstId = manager->activeSessionId();
    CHECK(!firstId.isEmpty());
    CHECK(manager->hasSession(firstId));
    CHECK(!manager->hasSession("nope"));

    CHECK(!manager->switchSession("nope").has_value());
    CHECK(manager->switchSession(firstId).has_value());

    auto created = manager->createSession("Work");
    CHECK(created.has_value());
    if (!created) {
        return testSummary("session_manager");
    }
    const QString workId = *created;
    CHECK_EQ(manager->activeSessionId(), workId);
    CHECK_EQ(manager->sessions().size(), 2);

    CHECK(manager->appendMessage(workId, makeMessage("user", "hi")).has_value());
    MessageData assistant = makeMessage("assistant", "answer");
    assistant.reasoning = "think";
    CHECK(manager->appendMessage(workId, assistant).has_value());
    CHECK_EQ(manager->messages(workId).size(), 2);
    // Empty ids are filled before persisting, so reload keeps stable identity.
    CHECK(!manager->messages(workId)[0].messageId.isEmpty());

    CHECK(!manager->appendMessage("nope", makeMessage("user", "x")).has_value());

    // Edit the user message: drop the whole tail and replace it.
    MessageData edited = makeMessage("user", "hi edited");
    CHECK(manager->replaceTail(workId, 0, {edited}).has_value());
    CHECK_EQ(manager->messages(workId).size(), 1);
    CHECK_EQ(manager->messages(workId)[0].content, QString("hi edited"));
    CHECK(!manager->replaceTail(workId, 5, {}).has_value());

    CHECK(manager->renameSession(workId, "Renamed").has_value());
    CHECK(!manager->renameSession("nope", "x").has_value());

    CHECK(!manager->deleteSession("nope").has_value());

    // Reopen: everything above must come back from the event log.
    opened->reset();
    auto reopened = SessionManager::open(dbPath);
    CHECK(reopened.has_value());
    if (!reopened) {
        return testSummary("session_manager");
    }
    auto& second = *reopened;
    CHECK_EQ(second->sessions().size(), 2);
    CHECK_EQ(second->activeSessionId(), workId);
    CHECK_EQ(second->session(workId)->title, QString("Renamed"));
    CHECK_EQ(second->messages(workId).size(), 1);
    CHECK_EQ(second->messages(workId)[0].content, QString("hi edited"));

    CHECK(second->deleteSession(workId).has_value());
    CHECK_EQ(second->sessions().size(), 1);
    CHECK(second->activeSessionId() != workId);
    CHECK(!second->deleteSession(second->activeSessionId()).has_value());

    auto cleared = second->clearMessages(second->activeSessionId());
    CHECK(cleared.has_value());
    CHECK_EQ(second->messages(second->activeSessionId()).size(), 0);

    return testSummary("session_manager");
}
