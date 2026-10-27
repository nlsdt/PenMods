// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include "ToolRuntime.h"

#include <QString>
#include <QStringList>

#include <functional>
#include <memory>
#include <optional>

namespace mod::chatbot {

// Executes shell_exec tool calls asynchronously. Owner of the process lifecycle:
// approval queue, timeout, output capture/truncation and cancellation. Uses
// callbacks instead of Qt signals so it can be host-tested without moc.
class ShellTool {
public:
    struct Callbacks {
        std::function<void(const QString& callId, const QString& command)> approvalRequested;
        std::function<void(const QString& callId, const QString& command)>  started;
        std::function<void(const QString& callId, bool success, const QString& summary, const QString& result)>
            finished;
    };

    ShellTool();
    ~ShellTool();

    ShellTool(const ShellTool&) = delete;
    ShellTool& operator=(const ShellTool&) = delete;

    void                     setConfig(const ShellConfig& config);
    [[nodiscard]] ShellConfig config() const;
    void                     setCallbacks(Callbacks callbacks);

    // Queues the command for approval. Returns a rejection reason when the tool
    // is disabled, the command hits the blocklist, or the call id is in flight.
    [[nodiscard]] std::optional<QString> request(const QString& callId, const QString& command);
    void                                 approve(const QString& callId);
    void                                 deny(const QString& callId);
    // Stops running processes and rejects every pending approval.
    void cancelAll(const QString& reason);

    [[nodiscard]] bool        busy() const;
    [[nodiscard]] bool        isRunning(const QString& callId) const;
    [[nodiscard]] bool        isPending(const QString& callId) const;
    [[nodiscard]] QStringList pendingIds() const;

private:
    struct Private;
    std::unique_ptr<Private> d;
};

// Pure formatting helpers, exposed for tests.
QString formatShellResult(
    int exitCode,
    bool crashed,
    const QString& stdoutText,
    const QString& stderrText,
    const ShellConfig& config);
QString formatShellTimeout(int timeoutMs, const QString& stdoutText, const QString& stderrText, const ShellConfig& config);

} // namespace mod::chatbot
