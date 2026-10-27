// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include <QByteArray>
#include <QHash>
#include <QString>
#include <QtGlobal>

namespace mod::chatbot {

// 一次请求的形态摘要。只统计实际发出去的内容，用于把 400 与
// “截断后 tool_calls 还在、reasoning 没了”直接对上。
struct RequestSummary {
    // 本次请求的 messages 条数（含 system）。
    int messages = 0;
    // 本次请求里 tool_calls 的总个数（不是 assistant 条数）。
    int toolCalls = 0;
    // 本次请求里带 reasoning 的 assistant 条数（是计数，不是布尔）。
    int reasoningSent = 0;
    // 历史里带 reasoning 的 assistant 条数。
    int historyReasoning = 0;
    // 历史里带 tool_calls 的 assistant 条数。
    int historyToolCalls = 0;
    // 上述 assistant 中 reasoning 为空的条数（400 的关键指标）。
    int historyToolCallsWithoutReasoning = 0;
    // 请求体字节数。
    qint64 payloadBytes = 0;

    QString toFields() const;
};

// 专用错误日志：<目录>/ai-errors.log。每次失败一行 key=value，
// 超过 maxBytes 轮转到 .1；同 session + status 每分钟最多 maxPerMinute 条。
// 只依赖 QtCore，宿主可直接测试。
class RequestLog {
public:
    explicit RequestLog(QString directory, qint64 maxBytes = 256 * 1024, int maxPerMinute = 30);

    // 返回 false 时 error 说明原因：目录/打开/写入失败，或被限流。
    bool recordFailure(
        int                   status,
        const QString&        errorText,
        const QByteArray&     responseBody,
        const QString&        sessionId,
        const QString&        model,
        const QString&        protocol,
        const RequestSummary& summary,
        QString*              error = nullptr
    );

    QString path() const;

    // 压平换行、脱敏（sk-… / Bearer …）、按 UTF-16 边界截断；测试也用它。
    static QString sanitize(const QString& text, int maxChars);

private:
    struct RateLimit {
        qint64 minute = 0;
        int    count  = 0;
    };

    bool allowWrite(const QString& key, QString* error);

    QString                   m_directory;
    qint64                    m_maxBytes;
    int                       m_maxPerMinute;
    QHash<QString, RateLimit> m_rateLimits;
};

} // namespace mod::chatbot
