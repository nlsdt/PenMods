// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/context/ContextAssembler.h"
#include "chatbot/tools/ToolRuntime.h"
#include "test_main.h"

#include <QJsonArray>
#include <QJsonObject>
#include <QString>

using namespace mod::chatbot;

namespace {

const char* kTwoCalls =
    R"([{"id":"c1","type":"function","function":{"name":"shell_exec","arguments":"{\"command\":\"ls\"}"}},)"
    R"({"id":"c2","type":"function","function":{"name":"web_search","arguments":"{\"query\":\"x\"}"}}])";

} // namespace

int main() {
    // ------------------------------------------------------- parseToolCalls
    {
        const QVector<ToolCallSpec> calls = parseToolCalls(kTwoCalls);
        CHECK_EQ(calls.size(), 2);
        if (calls.size() == 2) {
            CHECK(calls[0].id == QStringLiteral("c1"));
            CHECK(calls[0].name == QStringLiteral("shell_exec"));
            CHECK(calls[0].arguments.contains(QStringLiteral("ls")));
        }

        CHECK(parseToolCalls(QString()).isEmpty());
        CHECK(parseToolCalls(QStringLiteral("not json")).isEmpty());
        CHECK(parseToolCalls(QStringLiteral("{}")).isEmpty());

        const QVector<ToolCallSpec> messy = parseToolCalls(
            R"([{"id":"a","function":{"name":"x"}},{"id":"a","function":{"name":"dup"}},)"
            R"({"id":"","function":{"name":"noid"}},{"function":{"name":"missing"}}])");
        CHECK_EQ(messy.size(), 1);
        if (!messy.isEmpty()) CHECK(messy[0].name == QStringLiteral("x"));
    }

    // ---------------------------------------------------------- shell policy
    {
        const ShellConfig config = ShellConfig::defaultConfig();
        CHECK(!config.enabled);
        CHECK_EQ(config.timeoutMs, 10000);
        CHECK_EQ(config.maxOutputBytes, 4096);
        CHECK(config.isBlocked(QStringLiteral("sudo rm -rf /")));
        CHECK(config.isBlocked(QStringLiteral("REBOOT")));
        CHECK(!config.isBlocked(QStringLiteral("ls -la")));

        // Truncation never splits a UTF-8 sequence and marks the cut.
        ShellConfig small;
        small.maxOutputBytes = 4;
        const QString limited = small.truncate(QStringLiteral("中文内容"));
        CHECK(limited.endsWith(QStringLiteral("[输出已截断]")));
        const QString body = limited.left(limited.indexOf(QStringLiteral("\n...")));
        CHECK(body.toUtf8().size() <= 4);
        CHECK(body == QStringLiteral("中"));

        ShellConfig wide;
        wide.maxOutputBytes = 4096;
        CHECK(wide.truncate(QStringLiteral("short")) == QStringLiteral("short"));

        // Config round-trip.
        const ShellConfig parsed = ShellConfig::fromJson(
            QJsonObject{{QStringLiteral("enabled"), true},
                        {QStringLiteral("timeout_ms"), 500},
                        {QStringLiteral("max_output_bytes"), 128},
                        {QStringLiteral("blocklist"), QJsonArray{QStringLiteral("danger")}}});
        CHECK(parsed.enabled);
        CHECK_EQ(parsed.timeoutMs, 500);
        CHECK_EQ(parsed.maxOutputBytes, 128);
        CHECK_EQ(parsed.blocklist.size(), 1);
        CHECK(parsed.isBlocked(QStringLiteral("something danger here")));
        CHECK(parsed.toJson().value(QStringLiteral("timeout_ms")).toInt() == 500);
    }

    // -------------------------------------------------------------- batching
    {
        ToolBatch batch;
        CHECK(!batch.active());
        CHECK(!batch.complete());

        batch.beginFromJson(kTwoCalls);
        CHECK(batch.active());
        CHECK_EQ(batch.invocations().size(), 2);
        CHECK(!batch.complete());
        CHECK(batch.has(QStringLiteral("c1")));
        CHECK(!batch.has(QStringLiteral("nope")));

        CHECK(batch.markRunning(QStringLiteral("c1")));
        CHECK(batch.resolve(QStringLiteral("c1"), QStringLiteral("ok")));
        CHECK(!batch.resolve(QStringLiteral("c1"), QStringLiteral("again"))); // terminal
        CHECK(!batch.complete());                                            // c2 pending

        CHECK(batch.fail(QStringLiteral("c2"), QStringLiteral("boom")));
        CHECK(batch.complete());

        const QVector<MessageData> messages = batch.toToolMessages();
        CHECK_EQ(messages.size(), 2);
        if (messages.size() == 2) {
            CHECK(messages[0].role == QStringLiteral("tool"));
            CHECK(messages[0].toolCallId == QStringLiteral("c1"));
            CHECK(messages[0].content == QStringLiteral("ok"));
            CHECK(messages[1].toolCallId == QStringLiteral("c2"));
            CHECK(messages[1].content == QStringLiteral("boom"));
        }

        CHECK(!batch.markRunning(QStringLiteral("unknown")));
        CHECK(!batch.fail(QStringLiteral("unknown"), QStringLiteral("x")));
    }

    // -------------------------------------------------------------- cancel
    {
        ToolBatch batch;
        batch.beginFromJson(kTwoCalls);
        batch.resolve(QStringLiteral("c1"), QStringLiteral("done"));
        batch.cancelRemaining(QStringLiteral("user cancelled"));
        CHECK(batch.complete());

        const QVector<MessageData> messages = batch.toToolMessages();
        CHECK_EQ(messages.size(), 2);
        if (messages.size() == 2) {
            CHECK(messages[0].content == QStringLiteral("done"));
            CHECK(messages[1].content == QStringLiteral("user cancelled"));
        }

        // New batch replaces the old one.
        batch.begin({});
        CHECK(!batch.active());
        batch.beginFromJson(kTwoCalls);
        CHECK_EQ(batch.invocations().size(), 2);
        CHECK(batch.invocations()[0].state == ToolState::Pending);
    }

    // ------------------------------------------- unresolved calls get placeholder
    {
        ToolBatch batch;
        batch.beginFromJson(kTwoCalls);
        const QVector<MessageData> messages = batch.toToolMessages();
        CHECK_EQ(messages.size(), 2);
        if (!messages.isEmpty()) CHECK(messages[0].content == pendingToolResultText());
        CHECK(!batch.complete());
    }

    return testSummary("tools");
}
