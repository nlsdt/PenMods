// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "ShellTool.h"

#include <QHash>
#include <QProcess>
#include <QTimer>

namespace mod::chatbot {

namespace {

// The child keeps writing after we stop caring; keep reading (so it cannot block
// on a full pipe) but stop retaining bytes past this bound.
constexpr qint64 kMaxCaptureBytes = 1 << 20;

void appendBounded(QString& buffer, qint64* captured, const QByteArray& chunk) {
    const qint64 room = kMaxCaptureBytes - *captured;
    if (room <= 0) return;
    const QByteArray kept = chunk.size() > room ? chunk.left(static_cast<int>(room)) : chunk;
    *captured += kept.size();
    buffer += QString::fromUtf8(kept);
}

} // namespace

QString formatShellResult(
    int exitCode,
    bool crashed,
    const QString& stdoutText,
    const QString& stderrText,
    const ShellConfig& config) {
    const QString out = config.truncate(stdoutText);
    const QString err = config.truncate(stderrText, config.maxOutputBytes / 2);

    QString result = QStringLiteral("Exit code: %1\n").arg(exitCode);
    if (crashed) result += QStringLiteral("（进程崩溃）\n");
    if (!out.isEmpty()) result += QStringLiteral("stdout:\n") + out + QLatin1Char('\n');
    if (!err.isEmpty()) result += QStringLiteral("stderr:\n") + err + QLatin1Char('\n');
    return result;
}

QString formatShellTimeout(
    int timeoutMs,
    const QString& stdoutText,
    const QString& stderrText,
    const ShellConfig& config) {
    QString result = QStringLiteral("命令超时（%1ms）。\n").arg(timeoutMs);
    result += QStringLiteral("stdout:\n") + config.truncate(stdoutText) + QLatin1Char('\n');
    result += QStringLiteral("stderr:\n") + config.truncate(stderrText) + QLatin1Char('\n');
    return result;
}

struct ShellTool::Private {
    struct Active {
        QString                   command;
        std::unique_ptr<QProcess> process;
        std::unique_ptr<QTimer>   timer;
        QString                   stdoutBuf;
        QString                   stderrBuf;
        qint64                    stdoutCaptured = 0;
        qint64                    stderrCaptured = 0;
        bool                      done           = false;
    };

    ShellConfig                              config;
    Callbacks                                callbacks;
    QHash<QString, QString>                  pending; // callId -> command
    QHash<QString, std::shared_ptr<Active>>  running;

    void start(const QString& callId, const QString& command);
    void finish(const QString& callId, bool success, const QString& summary, const QString& result);
};

void ShellTool::Private::start(const QString& callId, const QString& command) {
    auto active       = std::make_shared<Active>();
    active->command   = command;
    active->process   = std::make_unique<QProcess>();
    active->process->setProgram(QStringLiteral("/bin/sh"));
    active->process->setArguments({QStringLiteral("-c"), command});
    active->process->setProcessChannelMode(QProcess::SeparateChannels);

    QProcess* process = active->process.get();
    running.insert(callId, active);

    QObject::connect(process, &QProcess::readyReadStandardOutput, process, [this, callId]() {
        const auto it = running.constFind(callId);
        if (it == running.constEnd()) return;
        const auto& entry = *it;
        appendBounded(entry->stdoutBuf, &entry->stdoutCaptured, entry->process->readAllStandardOutput());
    });
    QObject::connect(process, &QProcess::readyReadStandardError, process, [this, callId]() {
        const auto it = running.constFind(callId);
        if (it == running.constEnd()) return;
        const auto& entry = *it;
        appendBounded(entry->stderrBuf, &entry->stderrCaptured, entry->process->readAllStandardError());
    });
    QObject::connect(
        process,
        QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
        process,
        [this, callId](int exitCode, QProcess::ExitStatus status) {
            const auto it = running.constFind(callId);
            if (it == running.constEnd() || (*it)->done) return;
            const auto activeEntry = *it;
            activeEntry->done      = true;
            if (activeEntry->timer) activeEntry->timer->stop();

            const bool    crashed = status != QProcess::NormalExit;
            const bool    success = exitCode == 0 && !crashed;
            const QString summary = success ? QStringLiteral("执行成功")
                                            : (crashed ? QStringLiteral("进程崩溃")
                                                       : QStringLiteral("退出码: %1").arg(exitCode));
            const QString result = formatShellResult(
                exitCode,
                crashed,
                activeEntry->stdoutBuf,
                activeEntry->stderrBuf,
                config);
            finish(callId, success, summary, result);
        });
    QObject::connect(process, &QProcess::errorOccurred, process, [this, callId](QProcess::ProcessError error) {
        if (error != QProcess::FailedToStart) return;
        const auto it = running.constFind(callId);
        if (it == running.constEnd() || (*it)->done) return;
        (*it)->done = true;
        if ((*it)->timer) (*it)->timer->stop();
        finish(callId, false, QStringLiteral("启动失败"), QStringLiteral("命令启动失败，请检查命令是否正确。"));
    });

    if (config.timeoutMs > 0) {
        active->timer = std::make_unique<QTimer>();
        QTimer* timer = active->timer.get();
        timer->setSingleShot(true);
        QObject::connect(timer, &QTimer::timeout, timer, [this, callId]() {
            const auto it = running.constFind(callId);
            if (it == running.constEnd() || (*it)->done) return;
            (*it)->done = true;
            finish(
                callId,
                false,
                QStringLiteral("执行超时"),
                formatShellTimeout(config.timeoutMs, (*it)->stdoutBuf, (*it)->stderrBuf, config));
        });
        timer->start(config.timeoutMs);
    }

    if (callbacks.started) callbacks.started(callId, command);
    process->start();
}

void ShellTool::Private::finish(
    const QString& callId,
    bool success,
    const QString& summary,
    const QString& result) {
    // Remove first: a finished callback may start the next tool or cancel the rest.
    // Defer destruction: this runs inside QProcess::finished / QTimer::timeout, and
    // deleting those objects in their own signal handler is not safe.
    if (auto entry = running.take(callId)) {
        QTimer::singleShot(0, [entry]() {});
    }
    if (callbacks.finished) callbacks.finished(callId, success, summary, result);
}

ShellTool::ShellTool() : d(std::make_unique<Private>()) {}

ShellTool::~ShellTool() {
    for (auto it = d->running.begin(); it != d->running.end(); ++it) {
        if ((*it)->timer) (*it)->timer->stop();
        if ((*it)->process && (*it)->process->state() != QProcess::NotRunning) {
            (*it)->process->kill();
            (*it)->process->waitForFinished(200);
        }
    }
    d->running.clear();
}

void ShellTool::setConfig(const ShellConfig& config) { d->config = config; }

ShellConfig ShellTool::config() const { return d->config; }

void ShellTool::setCallbacks(Callbacks callbacks) { d->callbacks = std::move(callbacks); }

std::optional<QString> ShellTool::request(const QString& callId, const QString& command) {
    if (callId.isEmpty()) return QStringLiteral("工具调用 id 为空，本次没有执行。");
    if (d->pending.contains(callId) || d->running.contains(callId)) {
        return QStringLiteral("重复的工具调用，本次没有执行。");
    }
    if (!d->config.enabled) return QStringLiteral("Shell tool 未启用，本次没有执行。");
    if (command.trimmed().isEmpty()) return QStringLiteral("命令为空，本次没有执行。");
    if (d->config.isBlocked(command)) {
        return QStringLiteral("命令被安全策略拦截，本次没有执行。");
    }

    d->pending.insert(callId, command);
    if (d->callbacks.approvalRequested) d->callbacks.approvalRequested(callId, command);
    return std::nullopt;
}

void ShellTool::approve(const QString& callId) {
    const auto it = d->pending.find(callId);
    if (it == d->pending.end()) return;
    const QString command = it.value();
    d->pending.erase(it);
    d->start(callId, command);
}

void ShellTool::deny(const QString& callId) {
    const auto it = d->pending.find(callId);
    if (it == d->pending.end()) return;
    d->pending.erase(it);
    if (d->callbacks.finished) {
        d->callbacks.finished(
            callId,
            false,
            QStringLiteral("用户拒绝执行"),
            QStringLiteral("用户拒绝了该操作"));
    }
}

void ShellTool::cancelAll(const QString& reason) {
    const QStringList pending = d->pending.keys();
    d->pending.clear();
    for (const auto& callId : pending) {
        if (d->callbacks.finished) d->callbacks.finished(callId, false, reason, reason);
    }

    const QStringList running = d->running.keys();
    for (const auto& callId : running) {
        if (d->callbacks.finished) d->callbacks.finished(callId, false, reason, reason);
    }
    d->running.clear();
    // QProcess destructors below may be reached from inside a callback; they only
    // kill children, never touch the objects whose signals are being delivered.
}

bool ShellTool::busy() const { return !d->pending.isEmpty() || !d->running.isEmpty(); }

bool ShellTool::isRunning(const QString& callId) const { return d->running.contains(callId); }

bool ShellTool::isPending(const QString& callId) const { return d->pending.contains(callId); }

QStringList ShellTool::pendingIds() const { return d->pending.keys(); }

} // namespace mod::chatbot
