// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include "chatbot/core/MessageData.h"

#include <QJsonObject>
#include <QString>
#include <QStringList>
#include <QVector>

namespace mod::chatbot {

struct ToolCallSpec {
    QString id;
    QString name;
    QString arguments; // raw JSON string
};

// Parses the assistant tool_calls JSON. Invalid entries, empty ids and duplicate
// ids are dropped (same rule the request normalizer applies).
QVector<ToolCallSpec> parseToolCalls(const QString& toolCallsJson);

struct ShellConfig {
    bool        enabled        = false;
    int         timeoutMs      = 10000;
    int         maxOutputBytes = 4096;
    // Shell used to run commands. Empty means /bin/bash. Point it at another shell, a
    // wrapper, or a restricted shell without touching the code.
    QString     program;
    // Run commands as this user. Empty or "root" keeps the inherited identity;
    // anything else goes through the setuid sudo shim (`sudo -u <user>`).
    QString     runAs;
    // Optional script sourced (`.` builtin) before every command; a script that
    // cannot be sourced aborts the command with exit code 125.
    QString     sourceScript;
    QStringList blocklist;

    [[nodiscard]] static ShellConfig defaultConfig();
    [[nodiscard]] static ShellConfig fromJson(const QJsonObject& object);
    [[nodiscard]] QJsonObject        toJson() const;

    [[nodiscard]] bool isBlocked(const QString& command) const;
    // UTF-8-safe cut, appends a marker when anything was dropped.
    [[nodiscard]] QString truncate(const QString& output) const { return truncate(output, maxOutputBytes); }
    [[nodiscard]] QString truncate(const QString& output, int maxBytes) const;

    // Configured program, falling back to /bin/bash.
    [[nodiscard]] QString shellProgram() const;
    // The string handed to `<program> -c`: the user command wrapped in a source
    // prelude when sourceScript is set. Quoted so paths with spaces survive.
    [[nodiscard]] QString wrapCommand(const QString& command) const;
};

enum class ToolState {
    Pending,
    Running,
    Done,
    Error,
    Cancelled,
};

struct ToolInvocation {
    QString   callId;
    QString   name;
    QString   arguments;
    QString   result;
    ToolState state = ToolState::Pending;
};

// Batch state machine for one assistant message's tool_calls. The orchestrator
// resolves calls asynchronously (approval, process exit, HTTP reply); the batch
// is only flushed once every call reached a terminal state.
class ToolBatch {
public:
    void begin(const QVector<ToolCallSpec>& calls);
    void beginFromJson(const QString& toolCallsJson);

    [[nodiscard]] bool           active() const { return !m_invocations.isEmpty(); }
    [[nodiscard]] bool           complete() const;
    [[nodiscard]] bool           has(const QString& callId) const;
    [[nodiscard]] ToolInvocation invocation(const QString& callId) const;
    [[nodiscard]] const QVector<ToolInvocation>& invocations() const { return m_invocations; }

    bool markRunning(const QString& callId);
    bool resolve(const QString& callId, const QString& result);
    bool fail(const QString& callId, const QString& message);
    // Marks every non-terminal call as cancelled (user cancel, session switch).
    void cancelRemaining(const QString& reason);

    // Tool messages in call order, one per invocation. Unresolved calls get the
    // pending placeholder, so callers can flush after cancelRemaining().
    [[nodiscard]] QVector<MessageData> toToolMessages() const;

    void clear();

private:
    ToolInvocation* find(const QString& callId);

    QVector<ToolInvocation> m_invocations;
};

} // namespace mod::chatbot
