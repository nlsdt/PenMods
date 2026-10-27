// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/tools/ShellTool.h"
#include "test_main.h"

#include <QCoreApplication>
#include <QElapsedTimer>
#include <QEventLoop>
#include <QString>
#include <QStringList>
#include <QThread>

#include <functional>

using namespace mod::chatbot;

namespace {

struct FinishedCall {
    QString id;
    bool    success = false;
    QString summary;
    QString result;
};

bool waitFor(const std::function<bool()>& predicate, int timeoutMs = 5000) {
    QElapsedTimer timer;
    timer.start();
    while (!predicate() && timer.elapsed() < timeoutMs) {
        QCoreApplication::processEvents(QEventLoop::AllEvents, 20);
        QThread::msleep(5);
    }
    return predicate();
}

ShellConfig enabledConfig(int timeoutMs = 5000) {
    ShellConfig config = ShellConfig::defaultConfig();
    config.enabled     = true;
    config.timeoutMs   = timeoutMs;
    return config;
}

} // namespace

int main(int argc, char** argv) {
    QCoreApplication app(argc, argv);

    // ------------------------------------------------------- format helpers
    {
        ShellConfig config = enabledConfig();
        const QString result = formatShellResult(3, false, "out", "err", config);
        CHECK(result.startsWith(QStringLiteral("Exit code: 3\n")));
        CHECK(result.contains(QStringLiteral("stdout:\nout\n")));
        CHECK(result.contains(QStringLiteral("stderr:\nerr\n")));
        CHECK(formatShellResult(0, true, "", "", config).contains(QStringLiteral("进程崩溃")));
        CHECK(formatShellTimeout(1200, "o", "e", config).startsWith(QStringLiteral("命令超时（1200ms）。")));
    }

    ShellTool  tool;
    QStringList approvals;
    QStringList starts;
    QVector<FinishedCall> finished;

    tool.setCallbacks(ShellTool::Callbacks{
        [&](const QString& id, const QString& command) { approvals.append(id + QLatin1Char(':') + command); },
        [&](const QString& id, const QString& command) { starts.append(id + QLatin1Char(':') + command); },
        [&](const QString& id, bool ok, const QString& summary, const QString& result) {
            finished.append(FinishedCall{id, ok, summary, result});
        },
    });
    tool.setConfig(enabledConfig());

    // --------------------------------------------------- rejected up front
    {
        auto reason = tool.request(QStringLiteral("b1"), QStringLiteral("sudo reboot now"));
        CHECK(reason.has_value());
        CHECK(reason->contains(QStringLiteral("拦截")));
        CHECK(approvals.isEmpty());
        CHECK(!tool.busy());

        ShellConfig disabled = enabledConfig();
        disabled.enabled     = false;
        tool.setConfig(disabled);
        CHECK(tool.request(QStringLiteral("b2"), QStringLiteral("ls")).has_value());
        tool.setConfig(enabledConfig());

        CHECK(tool.request(QString(), QStringLiteral("ls")).has_value());
        CHECK(tool.request(QStringLiteral("b3"), QStringLiteral("   ")).has_value());
    }

    // ------------------------------------------------------------- approval
    {
        CHECK(!tool.request(QStringLiteral("c1"), QStringLiteral("echo hello")).has_value());
        CHECK(tool.isPending(QStringLiteral("c1")));
        CHECK(!tool.isRunning(QStringLiteral("c1")));
        CHECK(tool.busy());
        CHECK_EQ(approvals.size(), 1);

        tool.approve(QStringLiteral("c1"));
        CHECK(tool.isRunning(QStringLiteral("c1")));
        CHECK_EQ(starts.size(), 1);

        CHECK(waitFor([&]() { return !finished.isEmpty(); }));
        CHECK(!tool.isRunning(QStringLiteral("c1")));
        CHECK_EQ(finished.size(), 1);
        if (!finished.isEmpty()) {
            CHECK(finished[0].success);
            CHECK(finished[0].summary == QStringLiteral("执行成功"));
            CHECK(finished[0].result.contains(QStringLiteral("Exit code: 0")));
            CHECK(finished[0].result.contains(QStringLiteral("hello")));
        }

        // Approving an unknown / already finished id is a no-op.
        tool.approve(QStringLiteral("c1"));
        CHECK_EQ(starts.size(), 1);
    }

    // ----------------------------------------------------------- deny
    {
        finished.clear();
        CHECK(!tool.request(QStringLiteral("c2"), QStringLiteral("echo nope")).has_value());
        tool.deny(QStringLiteral("c2"));
        CHECK_EQ(finished.size(), 1);
        if (!finished.isEmpty()) {
            CHECK(!finished[0].success);
            CHECK(finished[0].summary == QStringLiteral("用户拒绝执行"));
            CHECK(finished[0].result.contains(QStringLiteral("拒绝")));
        }
        CHECK(!tool.isPending(QStringLiteral("c2")));
    }

    // ---------------------------------------------------------- non-zero
    {
        finished.clear();
        CHECK(!tool.request(QStringLiteral("c3"), QStringLiteral("exit 7")).has_value());
        tool.approve(QStringLiteral("c3"));
        CHECK(waitFor([&]() { return !finished.isEmpty(); }));
        if (!finished.isEmpty()) {
            CHECK(!finished[0].success);
            CHECK(finished[0].summary.contains(QStringLiteral("7")));
            CHECK(finished[0].result.contains(QStringLiteral("Exit code: 7")));
        }
    }

    // ------------------------------------------------------------ timeout
    {
        finished.clear();
        ShellConfig shortTimeout = enabledConfig(100);
        tool.setConfig(shortTimeout);

        QElapsedTimer elapsed;
        elapsed.start();
        CHECK(!tool.request(QStringLiteral("c4"), QStringLiteral("sleep 5")).has_value());
        tool.approve(QStringLiteral("c4"));
        CHECK(waitFor([&]() { return !finished.isEmpty(); }, 3000));
        CHECK(elapsed.elapsed() < 3000);
        if (!finished.isEmpty()) {
            CHECK(!finished[0].success);
            CHECK(finished[0].summary == QStringLiteral("执行超时"));
            CHECK(finished[0].result.contains(QStringLiteral("命令超时（100ms）")));
        }
        CHECK(!tool.busy());
    }

    // ------------------------------------------------------------ cancel
    {
        finished.clear();
        tool.setConfig(enabledConfig());
        CHECK(!tool.request(QStringLiteral("c5"), QStringLiteral("echo a")).has_value());
        CHECK(!tool.request(QStringLiteral("c6"), QStringLiteral("echo b")).has_value());
        tool.cancelAll(QStringLiteral("用户取消"));
        CHECK_EQ(finished.size(), 2);
        CHECK(!tool.busy());
        for (const auto& call : finished) {
            CHECK(!call.success);
            CHECK(call.summary == QStringLiteral("用户取消"));
        }

        // Cancel a running process too.
        finished.clear();
        CHECK(!tool.request(QStringLiteral("c7"), QStringLiteral("sleep 5")).has_value());
        tool.approve(QStringLiteral("c7"));
        CHECK(waitFor([&]() { return tool.isRunning(QStringLiteral("c7")); }, 2000));
        tool.cancelAll(QStringLiteral("中断"));
        CHECK(waitFor([&]() { return !finished.isEmpty(); }, 3000));
        if (!finished.isEmpty()) CHECK(finished[0].result == QStringLiteral("中断"));
        CHECK(!tool.busy());
    }

    return testSummary("shell_tool");
}
