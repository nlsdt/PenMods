// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/core/RequestLog.h"

#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QRegularExpression>

#include <utility>

namespace mod::chatbot {

namespace {

constexpr int kMaxErrorChars = 120;
constexpr int kMaxIdChars    = 80;
constexpr int kMaxBodyChars  = 200;

// 中转站常把请求体或 Authorization 回显在 400 响应里，落盘前统一抹掉。
QString redactSecrets(const QString& text) {
    static const QRegularExpression keyPattern(QStringLiteral("sk-[A-Za-z0-9_-]{8,}"));
    static const QRegularExpression bearerPattern(
        QStringLiteral("Bearer\\s+\\S+"),
        QRegularExpression::CaseInsensitiveOption
    );
    QString redacted = text;
    redacted.replace(keyPattern, QStringLiteral("***"));
    redacted.replace(bearerPattern, QStringLiteral("Bearer ***"));
    return redacted;
}

// left() 可能把代理对切成两半，留下孤立的 high surrogate；退一格保证 UTF-8 可往返。
QString truncateUtf16Safe(const QString& text, int maxChars) {
    if (maxChars <= 0 || text.size() <= maxChars) return text;
    int end = maxChars;
    if (text.at(end - 1).isHighSurrogate() && text.at(end).isLowSurrogate()) --end;
    return text.left(end);
}

} // namespace

QString RequestSummary::toFields() const {
    const QString fields = QStringLiteral(
                               "messages=%1 tool_calls=%2 reasoning_sent=%3 history_reasoning=%4 history_tool_calls=%5 "
                               "history_tool_calls_without_reasoning=%6 payload=%7"
    )
                               .arg(messages)
                               .arg(toolCalls)
                               .arg(reasoningSent)
                               .arg(historyReasoning)
                               .arg(historyToolCalls)
                               .arg(historyToolCallsWithoutReasoning)
                               .arg(payloadBytes);
    return fields + QLatin1Char('B');
}

RequestLog::RequestLog(QString directory, qint64 maxBytes, int maxPerMinute)
: m_directory(std::move(directory)),
  m_maxBytes(maxBytes > 0 ? maxBytes : 256 * 1024),
  m_maxPerMinute(maxPerMinute) {}

QString RequestLog::path() const { return QDir(m_directory).filePath(QStringLiteral("ai-errors.log")); }

QString RequestLog::sanitize(const QString& text, int maxChars) {
    QString sanitized = text;
    sanitized.replace(QLatin1Char('\r'), QLatin1Char(' '))
        .replace(QLatin1Char('\n'), QLatin1Char(' '))
        .replace(QLatin1Char('\t'), QLatin1Char(' '));
    return truncateUtf16Safe(redactSecrets(sanitized), maxChars);
}

bool RequestLog::allowWrite(const QString& key, QString* error) {
    if (m_maxPerMinute <= 0) return true;

    const qint64 minute = QDateTime::currentSecsSinceEpoch() / 60;
    RateLimit&   limit  = m_rateLimits[key];
    if (limit.minute != minute) {
        limit.minute = minute;
        limit.count  = 0;
    }
    if (limit.count >= m_maxPerMinute) {
        if (error) *error = QStringLiteral("已限流（%1，每分钟最多 %2 条）").arg(key).arg(m_maxPerMinute);
        return false;
    }
    ++limit.count;
    return true;
}

bool RequestLog::recordFailure(
    int                   status,
    const QString&        errorText,
    const QByteArray&     responseBody,
    const QString&        sessionId,
    const QString&        model,
    const QString&        protocol,
    const RequestSummary& summary,
    QString*              error
) {
    const QString cleanSession = sanitize(sessionId, kMaxIdChars);
    QString       problem;
    if (!allowWrite(cleanSession + QLatin1Char('|') + QString::number(status), &problem)) {
        if (error) *error = problem;
        return false;
    }

    const QString line = QStringLiteral("%1 status=%2 err=%3 session=%4 model=%5 protocol=%6 %7 body=%8")
                             .arg(QDateTime::currentDateTime().toString(Qt::ISODate))
                             .arg(status)
                             .arg(sanitize(errorText, kMaxErrorChars))
                             .arg(cleanSession)
                             .arg(sanitize(model, kMaxIdChars))
                             .arg(protocol)
                             .arg(summary.toFields())
                             .arg(sanitize(QString::fromUtf8(responseBody), kMaxBodyChars));

    if (!QDir().mkpath(m_directory)) {
        problem = QStringLiteral("无法创建日志目录: %1").arg(m_directory);
    } else {
        const QString filePath = path();
        if (QFileInfo(filePath).size() > m_maxBytes) {
            QFile::remove(filePath + QStringLiteral(".1"));
            if (!QFile::rename(filePath, filePath + QStringLiteral(".1")) && QFileInfo::exists(filePath))
                problem = QStringLiteral("无法轮转日志: %1").arg(filePath);
        }

        QFile file(filePath);
        if (!file.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
            problem = QStringLiteral("无法打开日志: %1").arg(filePath);
        } else {
            QByteArray data = line.toUtf8();
            data.append('\n');
            if (file.write(data) != data.size() || !file.flush())
                problem = QStringLiteral("写入日志失败: %1").arg(filePath);
        }
    }

    if (error) *error = problem;
    return problem.isEmpty();
}

} // namespace mod::chatbot
