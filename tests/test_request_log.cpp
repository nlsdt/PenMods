// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/core/RequestLog.h"
#include "test_main.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QTemporaryDir>

using mod::chatbot::RequestLog;
using mod::chatbot::RequestSummary;

namespace {

RequestSummary sampleSummary() {
    RequestSummary summary;
    summary.messages                         = 100;
    summary.toolCalls                        = 37;
    summary.reasoningSent                    = 0;
    summary.historyReasoning                 = 12;
    summary.historyToolCalls                 = 37;
    summary.historyToolCallsWithoutReasoning = 37;
    summary.payloadBytes                     = 123456;
    return summary;
}

QString readAll(const QString& path) {
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return {};
    return QString::fromUtf8(file.readAll());
}

QString bodyField(const QString& line) {
    const int index = line.indexOf(QStringLiteral("body="));
    return index < 0 ? QString() : line.mid(index + 5);
}

void testSanitize() {
    CHECK_EQ(RequestLog::sanitize(QStringLiteral("a\nb\tc\r"), 100), QStringLiteral("a b c "));
    CHECK_EQ(RequestLog::sanitize(QString(300, QLatin1Char('x')), 200).size(), 200);
    CHECK_EQ(RequestLog::sanitize(QStringLiteral("abc"), 0), QStringLiteral("abc"));
}

void testRecordFailure() {
    QTemporaryDir dir;
    CHECK(dir.isValid());

    RequestLog log(dir.path());
    CHECK_EQ(log.path(), QDir(dir.path()).filePath(QStringLiteral("ai-errors.log")));

    QString       error;
    const QString line = QStringLiteral("first\nsecond\tthird");
    CHECK(log.recordFailure(
        400,
        QStringLiteral("Bad Request"),
        line.toUtf8(),
        QStringLiteral("session-1"),
        QStringLiteral("deepseek-chat"),
        QStringLiteral("chat_completions"),
        sampleSummary(),
        &error
    ));
    CHECK(error.isEmpty());

    const QString     content = readAll(log.path());
    const QStringList lines   = content.split(QLatin1Char('\n'), Qt::SkipEmptyParts);
    CHECK_EQ(lines.size(), 1);
    if (lines.isEmpty()) return;

    const QString& logged = lines.first();
    CHECK(logged.contains(QStringLiteral("status=400")));
    CHECK(logged.contains(QStringLiteral("err=Bad Request")));
    CHECK(logged.contains(QStringLiteral("session=session-1")));
    CHECK(logged.contains(QStringLiteral("model=deepseek-chat")));
    CHECK(logged.contains(QStringLiteral("protocol=chat_completions")));
    CHECK(logged.contains(QStringLiteral("messages=100")));
    CHECK(logged.contains(QStringLiteral("tool_calls=37")));
    CHECK(logged.contains(QStringLiteral("reasoning_sent=0")));
    CHECK(logged.contains(QStringLiteral("history_reasoning=12")));
    CHECK(logged.contains(QStringLiteral("history_tool_calls=37")));
    CHECK(logged.contains(QStringLiteral("history_tool_calls_without_reasoning=37")));
    CHECK(logged.contains(QStringLiteral("payload=123456B")));
    CHECK(logged.contains(QStringLiteral("first second third")));
    CHECK(!logged.contains(QLatin1Char('\t')));
    CHECK(bodyField(logged).size() <= 200);
}

void testBodyTruncation() {
    QTemporaryDir dir;
    CHECK(dir.isValid());

    RequestLog log(dir.path());
    QString    error;
    CHECK(log.recordFailure(
        400,
        QStringLiteral("Bad Request"),
        QByteArray(500, 'a'),
        QStringLiteral("s"),
        QStringLiteral("m"),
        QStringLiteral("chat_completions"),
        sampleSummary(),
        &error
    ));
    CHECK(error.isEmpty());

    const QString     content = readAll(log.path());
    const QStringList lines   = content.split(QLatin1Char('\n'), Qt::SkipEmptyParts);
    CHECK_EQ(lines.size(), 1);
    if (lines.isEmpty()) return;
    CHECK_EQ(bodyField(lines.first()).size(), 200);
}

void testRotation() {
    QTemporaryDir dir;
    CHECK(dir.isValid());

    RequestLog log(dir.path(), 200);
    QString    error;
    for (int i = 0; i < 3; ++i) {
        CHECK(log.recordFailure(
            400,
            QStringLiteral("Bad Request"),
            QByteArray(500, 'b'),
            QStringLiteral("s"),
            QStringLiteral("m"),
            QStringLiteral("chat_completions"),
            sampleSummary(),
            &error
        ));
        CHECK(error.isEmpty());
    }

    CHECK(QFileInfo(dir.filePath(QStringLiteral("ai-errors.log.1"))).exists());
    CHECK(QFileInfo(log.path()).size() > 0);
}

void testDirectoryCreation() {
    QTemporaryDir dir;
    CHECK(dir.isValid());

    const QString nested = QDir(dir.path()).filePath(QStringLiteral("a/b/c"));
    RequestLog    log(nested);
    QString       error;
    CHECK(log.recordFailure(
        0,
        QStringLiteral("TimeoutError"),
        QByteArray(),
        QStringLiteral("s"),
        QStringLiteral("m"),
        QStringLiteral("responses"),
        sampleSummary(),
        &error
    ));
    CHECK(error.isEmpty());
    CHECK(QFileInfo(log.path()).exists());
}

void testRedaction() {
    const QString text = QStringLiteral("Authorization: Bearer abc.def.ghi\nkey=sk-abcdefgh12345678");
    const QString safe = RequestLog::sanitize(text, 200);
    CHECK(safe.contains(QStringLiteral("Bearer ***")));
    CHECK(safe.contains(QStringLiteral("***")));
    CHECK(!safe.contains(QStringLiteral("abc.def.ghi")));
    CHECK(!safe.contains(QStringLiteral("sk-abcdefgh12345678")));

    QTemporaryDir dir;
    CHECK(dir.isValid());
    RequestLog log(dir.path());
    QString    error;
    CHECK(log.recordFailure(
        400,
        QStringLiteral("Bad Request"),
        text.toUtf8(),
        QStringLiteral("s"),
        QStringLiteral("m"),
        QStringLiteral("chat_completions"),
        sampleSummary(),
        &error
    ));
    CHECK(error.isEmpty());

    const QString logged = readAll(log.path()).trimmed();
    CHECK(!logged.contains(QStringLiteral("sk-abcdefgh12345678")));
    CHECK(!logged.contains(QStringLiteral("abc.def.ghi")));
    CHECK(logged.contains(QStringLiteral("***")));
}

void testUtf8Truncation() {
    QString text;
    for (int i = 0; i < 300; ++i) text += QString::fromUtf8("\xF0\x9F\x98\x80"); // 😀

    const QString safe = RequestLog::sanitize(text, 200);
    CHECK(safe.size() <= 200);
    CHECK(!safe.isEmpty());
    CHECK(!safe.at(safe.size() - 1).isHighSurrogate());
    // 孤立代理对转成 UTF-8 会变成 U+FFFD，往返即不相等。
    CHECK(QString::fromUtf8(safe.toUtf8()) == safe);

    QTemporaryDir dir;
    CHECK(dir.isValid());
    RequestLog log(dir.path());
    QString    error;
    CHECK(log.recordFailure(
        400,
        QStringLiteral("Bad Request"),
        text.toUtf8(),
        QStringLiteral("s"),
        QStringLiteral("m"),
        QStringLiteral("chat_completions"),
        sampleSummary(),
        &error
    ));
    CHECK(error.isEmpty());
    const QString field = bodyField(readAll(log.path()).trimmed());
    CHECK(field.size() <= 200);
    CHECK(QString::fromUtf8(field.toUtf8()) == field);
}

void testWriteFailure() {
    QTemporaryDir dir;
    CHECK(dir.isValid());

    // 父路径是普通文件：mkpath 必然失败，不依赖 chmod/只读目录。
    const QString blocked = QDir(dir.path()).filePath(QStringLiteral("blocked"));
    QFile         blocker(blocked);
    CHECK(blocker.open(QIODevice::WriteOnly));
    CHECK(blocker.write("x") == 1);
    blocker.close();

    RequestLog log(blocked);
    QString    error;
    const bool ok = log.recordFailure(
        400,
        QStringLiteral("Bad Request"),
        QByteArray(),
        QStringLiteral("s"),
        QStringLiteral("m"),
        QStringLiteral("chat_completions"),
        sampleSummary(),
        &error
    );
    CHECK(!ok);
    CHECK(!error.isEmpty());
}

void testRateLimit() {
    QTemporaryDir dir;
    CHECK(dir.isValid());

    RequestLog log(dir.path(), 256 * 1024, 2);
    for (int i = 0; i < 2; ++i) {
        QString error;
        CHECK(log.recordFailure(
            400,
            QStringLiteral("Bad Request"),
            QByteArray(100, 'r'),
            QStringLiteral("session-rate"),
            QStringLiteral("m"),
            QStringLiteral("chat_completions"),
            sampleSummary(),
            &error
        ));
        CHECK(error.isEmpty());
    }

    QString    error;
    const bool ok = log.recordFailure(
        400,
        QStringLiteral("Bad Request"),
        QByteArray(100, 'r'),
        QStringLiteral("session-rate"),
        QStringLiteral("m"),
        QStringLiteral("chat_completions"),
        sampleSummary(),
        &error
    );
    CHECK(!ok);
    CHECK(error.contains(QStringLiteral("限流")));

    const QStringList lines = readAll(log.path()).split(QLatin1Char('\n'), Qt::SkipEmptyParts);
    CHECK_EQ(lines.size(), 2);
}

} // namespace

int main() {
    testSanitize();
    testRecordFailure();
    testBodyTruncation();
    testRotation();
    testDirectoryCreation();
    testRedaction();
    testUtf8Truncation();
    testWriteFailure();
    testRateLimit();
    return testSummary("test_request_log");
}
