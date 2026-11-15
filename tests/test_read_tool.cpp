// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/tools/ReadTool.h"
#include "test_main.h"

#include <QByteArray>
#include <QFile>
#include <QString>
#include <QTemporaryDir>

using namespace mod::chatbot;

namespace {

QString writeFile(const QTemporaryDir& dir, const QString& name, const QByteArray& data) {
    const QString path = dir.filePath(name);
    QFile         file(path);
    if (file.open(QIODevice::WriteOnly)) file.write(data);
    return path;
}

} // namespace

int main() {
    {
        // 文本：行号、offset/limit、越界提示。
        QTemporaryDir dir;
        CHECK(dir.isValid());
        const QString path = writeFile(dir, "a.txt", QByteArray("alpha\nbeta\ngamma\ndelta\n"));

        auto all = ReadTool::readFile(path);
        CHECK(all.ok);
        CHECK(!all.isImage);
        CHECK_EQ(all.text, QString("1\talpha\n2\tbeta\n3\tgamma\n4\tdelta\n"));

        auto slice = ReadTool::readFile(path, 2, 2);
        CHECK(slice.ok);
        CHECK_EQ(slice.text, QString("2\tbeta\n3\tgamma\n…（共 4 行，已截断到第 3 行，可用 offset 继续）\n"));

        auto beyond = ReadTool::readFile(path, 99);
        CHECK(beyond.ok);
        CHECK(beyond.text.contains(QStringLiteral("超出范围")));
    }

    {
        // 缺失、目录、空路径、二进制。
        QTemporaryDir dir;
        CHECK(dir.isValid());
        CHECK(!ReadTool::readFile(dir.filePath("missing.txt")).ok);
        CHECK(!ReadTool::readFile(dir.path()).ok);
        CHECK(!ReadTool::readFile(QString()).ok);

        const QString bin = writeFile(dir, "bin.dat", QByteArray("ab\0cd", 5));
        auto          res = ReadTool::readFile(bin);
        CHECK(!res.ok);
        CHECK(res.error.contains(QStringLiteral("二进制")));
    }

    {
        // 图片按内容嗅探，不依赖扩展名。
        QTemporaryDir dir;
        CHECK(dir.isValid());
        QByteArray png("\x89PNG\r\n\x1a\n", 8);
        png.append(QByteArray(32, '\0'));
        const QString path = writeFile(dir, "shot.bin", png);

        auto res = ReadTool::readFile(path);
        CHECK(res.ok);
        CHECK(res.isImage);
        CHECK_EQ(res.mimeType, QString("image/png"));
        CHECK_EQ(res.imageBytes.size(), png.size());
    }

    return testSummary("read_tool");
}
