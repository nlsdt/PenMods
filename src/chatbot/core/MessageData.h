// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include <QString>
#include <QUuid>
#include <QVariantList>
#include <QVector>
#include <QtGlobal>

namespace mod::chatbot {

// 消息内容部分（多模态）
struct MessagePart {
    QString type;      // "text" | "image_url" | "input_audio"
    QString text;      // type=text
    QString url;       // type=image_url：HTTP URL 或 data:image/...;base64,...
    QString data;      // type=input_audio：base64 音频数据
    QString format;    // type=input_audio：格式 (mp3/wav/ogg 等)
    QString localPath; // 持久化附件的绝对路径
    QString name;      // 附件显示名称
    QString mimeType;  // 附件 MIME 类型
    QString language;  // 文本附件的语法语言
    qint64  size = 0;  // 附件字节数
};

// 单条消息（纯文本或多模态）
struct MessageData {
    QString              messageId = QUuid::createUuid().toString(QUuid::WithoutBraces);
    // Local display metadata. messageToJson deliberately excludes these fields.
    QVariantList         toolStates;
    QString              role;          // "user" | "assistant" | "system" | "tool"
    QString              content;       // 纯文本（无多模态时使用）
    QString              reasoning;     // 思考内容：带 tools 的请求必须回传
    QVector<MessagePart> parts;         // 多模态内容（非空时优先于 content）
    QString              toolCallId;    // role=tool 时
    QString              toolCallsJson; // role=assistant 且有 tool_calls 时，原始 JSON 字符串

    bool isMultimodal() const { return !parts.isEmpty(); }
};

} // namespace mod::chatbot
