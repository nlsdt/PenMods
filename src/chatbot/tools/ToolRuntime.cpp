// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "ToolRuntime.h"

#include "chatbot/context/ContextAssembler.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSet>

namespace mod::chatbot {

namespace {

bool isTerminal(ToolState state) {
    return state == ToolState::Done || state == ToolState::Error || state == ToolState::Cancelled;
}

} // namespace

QVector<ToolCallSpec> parseToolCalls(const QString& toolCallsJson) {
    QVector<ToolCallSpec> calls;
    if (toolCallsJson.isEmpty()) return calls;

    const QJsonDocument document = QJsonDocument::fromJson(toolCallsJson.toUtf8());
    if (!document.isArray()) return calls;

    QSet<QString> seen;
    for (const auto& value : document.array()) {
        const QJsonObject call     = value.toObject();
        const QString     id       = call.value(QStringLiteral("id")).toString().trimmed();
        const QJsonObject function = call.value(QStringLiteral("function")).toObject();
        const QString     name     = function.value(QStringLiteral("name")).toString();
        if (id.isEmpty() || seen.contains(id)) continue;
        seen.insert(id);

        ToolCallSpec spec;
        spec.id        = id;
        spec.name      = name;
        spec.arguments = function.value(QStringLiteral("arguments")).toString();
        calls.append(std::move(spec));
    }
    return calls;
}

ShellConfig ShellConfig::defaultConfig() {
    ShellConfig config;
    config.blocklist = QStringList{
        QStringLiteral("rm -rf /"),
        QStringLiteral("rm -rf /*"),
        QStringLiteral("mkfs"),
        QStringLiteral("dd if="),
        QStringLiteral(":(){ :|:&"),
        QStringLiteral("> /dev/sd"),
        QStringLiteral("chmod -R 777 /"),
        QStringLiteral("shutdown"),
        QStringLiteral("reboot"),
        QStringLiteral("init 0"),
        QStringLiteral("init 6"),
        QStringLiteral("halt"),
        QStringLiteral("fdisk"),
        QStringLiteral("mount -o remount"),
    };
    return config;
}

ShellConfig ShellConfig::fromJson(const QJsonObject& object) {
    ShellConfig config = defaultConfig();
    config.enabled     = object.value(QStringLiteral("enabled")).toBool(config.enabled);
    config.timeoutMs   = object.value(QStringLiteral("timeout_ms")).toInt(config.timeoutMs);
    config.maxOutputBytes =
        object.value(QStringLiteral("max_output_bytes")).toInt(config.maxOutputBytes);

    if (object.value(QStringLiteral("blocklist")).isArray()) {
        config.blocklist.clear();
        for (const auto& value : object.value(QStringLiteral("blocklist")).toArray()) {
            config.blocklist.append(value.toString());
        }
    }
    return config;
}

QJsonObject ShellConfig::toJson() const {
    QJsonArray list;
    for (const auto& entry : blocklist) list.append(entry);
    return QJsonObject{
        {QStringLiteral("enabled"), enabled},
        {QStringLiteral("timeout_ms"), timeoutMs},
        {QStringLiteral("max_output_bytes"), maxOutputBytes},
        {QStringLiteral("blocklist"), list},
    };
}

bool ShellConfig::isBlocked(const QString& command) const {
    const QString trimmed = command.trimmed();
    for (const auto& pattern : blocklist) {
        if (trimmed.contains(pattern, Qt::CaseInsensitive)) return true;
    }
    return false;
}

QString ShellConfig::truncate(const QString& output, int maxBytes) const {
    if (maxBytes <= 0) return output;

    const QByteArray bytes = output.toUtf8();
    if (bytes.size() <= maxBytes) return output;

    QByteArray cut = bytes.left(maxBytes);
    // Do not split a UTF-8 sequence: walk back to its leading byte and drop the
    // whole code point when it does not fit.
    int index = cut.size() - 1;
    while (index > 0 && (static_cast<unsigned char>(cut.at(index)) & 0xC0) == 0x80) --index;
    const unsigned char lead = static_cast<unsigned char>(cut.at(index));
    int                 need = 1;
    if ((lead & 0xE0) == 0xC0) need = 2;
    else if ((lead & 0xF0) == 0xE0) need = 3;
    else if ((lead & 0xF8) == 0xF0) need = 4;
    if (cut.size() - index < need) cut.truncate(index);
    return QString::fromUtf8(cut) + QStringLiteral("\n... [输出已截断]");
}

void ToolBatch::begin(const QVector<ToolCallSpec>& calls) {
    m_invocations.clear();
    m_invocations.reserve(calls.size());
    for (const auto& call : calls) {
        ToolInvocation invocation;
        invocation.callId    = call.id;
        invocation.name      = call.name;
        invocation.arguments = call.arguments;
        m_invocations.append(std::move(invocation));
    }
}

void ToolBatch::beginFromJson(const QString& toolCallsJson) { begin(parseToolCalls(toolCallsJson)); }

bool ToolBatch::complete() const {
    if (m_invocations.isEmpty()) return false;
    for (const auto& invocation : m_invocations) {
        if (!isTerminal(invocation.state)) return false;
    }
    return true;
}

bool ToolBatch::has(const QString& callId) const {
    for (const auto& invocation : m_invocations) {
        if (invocation.callId == callId) return true;
    }
    return false;
}

ToolInvocation ToolBatch::invocation(const QString& callId) const {
    for (const auto& invocation : m_invocations) {
        if (invocation.callId == callId) return invocation;
    }
    return {};
}

ToolInvocation* ToolBatch::find(const QString& callId) {
    for (auto& invocation : m_invocations) {
        if (invocation.callId == callId) return &invocation;
    }
    return nullptr;
}

bool ToolBatch::markRunning(const QString& callId) {
    ToolInvocation* invocation = find(callId);
    if (!invocation || isTerminal(invocation->state)) return false;
    invocation->state = ToolState::Running;
    return true;
}

bool ToolBatch::resolve(const QString& callId, const QString& result) {
    ToolInvocation* invocation = find(callId);
    if (!invocation || isTerminal(invocation->state)) return false;
    invocation->state  = ToolState::Done;
    invocation->result = result;
    return true;
}

bool ToolBatch::fail(const QString& callId, const QString& message) {
    ToolInvocation* invocation = find(callId);
    if (!invocation || isTerminal(invocation->state)) return false;
    invocation->state  = ToolState::Error;
    invocation->result = message;
    return true;
}

void ToolBatch::cancelRemaining(const QString& reason) {
    for (auto& invocation : m_invocations) {
        if (isTerminal(invocation.state)) continue;
        invocation.state  = ToolState::Cancelled;
        invocation.result = reason;
    }
}

QVector<MessageData> ToolBatch::toToolMessages() const {
    QVector<MessageData> messages;
    messages.reserve(m_invocations.size());
    for (const auto& invocation : m_invocations) {
        MessageData message;
        message.role       = QStringLiteral("tool");
        message.toolCallId = invocation.callId;
        if (!isTerminal(invocation.state)) {
            message.content = pendingToolResultText();
        } else if (!invocation.result.isEmpty()) {
            message.content = invocation.result;
        } else if (invocation.state == ToolState::Error) {
            message.content = QStringLiteral("工具执行失败");
        } else if (invocation.state == ToolState::Cancelled) {
            message.content = pendingToolResultText();
        }
        messages.append(std::move(message));
    }
    return messages;
}

void ToolBatch::clear() { m_invocations.clear(); }

} // namespace mod::chatbot
