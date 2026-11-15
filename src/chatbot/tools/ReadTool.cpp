// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/tools/ReadTool.h"

#include <QFile>
#include <QFileInfo>
#include <QMimeDatabase>

namespace mod::chatbot {

namespace {

bool isImageMime(const QString& mime) { return mime.startsWith(QLatin1String("image/")); }

} // namespace

ReadResult ReadTool::readFile(const QString& path, int offset, int limit) {
    ReadResult result;

    if (path.trimmed().isEmpty()) {
        result.error = QStringLiteral("路径为空");
        return result;
    }

    const QFileInfo info(path);
    if (!info.exists()) {
        result.error = QStringLiteral("文件不存在: ") + path;
        return result;
    }
    if (!info.isFile()) {
        result.error = QStringLiteral("不是普通文件: ") + path;
        return result;
    }
    if (!info.isReadable()) {
        result.error = QStringLiteral("没有读取权限: ") + path;
        return result;
    }
    result.size = info.size();

    // 用内容而不是后缀判断类型：很多现场文件没有扩展名。
    QMimeDatabase mimeDb;
    const QString  mime = mimeDb.mimeTypeForFile(info, QMimeDatabase::MatchContent).name();
    if (isImageMime(mime)) {
        if (info.size() > kMaxImageBytes) {
            result.error = QStringLiteral("图片过大（%1 字节，上限 %2）").arg(info.size()).arg(kMaxImageBytes);
            return result;
        }
        QFile file(info.absoluteFilePath());
        if (!file.open(QIODevice::ReadOnly)) {
            result.error = QStringLiteral("无法打开: ") + path;
            return result;
        }
        result.imageBytes = file.readAll();
        result.isImage    = true;
        result.mimeType   = mime;
        result.ok         = true;
        return result;
    }

    if (info.size() > kMaxTextBytes) {
        result.error = QStringLiteral("文件过大（%1 字节，上限 %2），请用 shell 分段读取")
                           .arg(info.size())
                           .arg(kMaxTextBytes);
        return result;
    }

    QFile file(info.absoluteFilePath());
    if (!file.open(QIODevice::ReadOnly)) {
        result.error = QStringLiteral("无法打开: ") + path;
        return result;
    }
    const QByteArray data = file.read(kMaxTextBytes);
    // 含 NUL 的按二进制处理，避免把可执行文件/数据库灌进上下文。
    if (data.contains('\0')) {
        result.error = QStringLiteral("二进制文件，无法作为文本读取: ") + path;
        return result;
    }

    QStringList lines = QString::fromUtf8(data).split(QLatin1Char('\n'));
    // 末尾换行会产生一个空行，去掉以免行号虚高。
    if (!lines.isEmpty() && lines.last().isEmpty()) lines.removeLast();

    const int startLine = qMax(0, offset > 0 ? offset - 1 : 0);
    if (startLine >= lines.size()) {
        result.text = QStringLiteral("（文件共 %1 行，起始行 %2 超出范围）").arg(lines.size()).arg(startLine + 1);
        result.ok   = true;
        return result;
    }

    const int maxLines = limit > 0 ? qMin(limit, kMaxLines) : kMaxLines;
    const int endLine  = qMin(lines.size(), startLine + maxLines);

    QString out;
    for (int line = startLine; line < endLine; ++line) {
        out += QStringLiteral("%1\t%2\n").arg(line + 1).arg(lines.at(line));
    }
    if (endLine < lines.size()) {
        out += QStringLiteral("…（共 %1 行，已截断到第 %2 行，可用 offset 继续）\n")
                   .arg(lines.size())
                   .arg(endLine);
    }
    result.text = out;
    result.ok   = true;
    return result;
}

} // namespace mod::chatbot
