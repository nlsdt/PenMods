// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include <QByteArray>
#include <QString>

namespace mod::chatbot {

// 一次读取的结果：文本文件给出带行号的内容，图片给出原始字节供上层转成
// image_url part（多模态），两者都不会把大文件整个塞进工具消息。
struct ReadResult {
    bool     ok = false;
    QString  error;
    QString  text;      // 文本内容（已带行号/截断说明）
    bool     isImage = false;
    QByteArray imageBytes;
    QString  mimeType;
    int      width = 0;
    int      height = 0;
    qint64   size = 0;
};

class ReadTool {
public:
    // offset 是 1-based 起始行（0 视作 1），limit 为最多返回的行数（<=0 表示默认上限）。
    static ReadResult readFile(const QString& path, int offset = 0, int limit = 0);

    static constexpr qint64 kMaxTextBytes = 256 * 1024;
    static constexpr qint64 kMaxImageBytes = 8 * 1024 * 1024;
    static constexpr int    kMaxLines = 2000;
};

} // namespace mod::chatbot
