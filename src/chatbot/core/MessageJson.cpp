// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "MessageJson.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonValue>

namespace mod::chatbot {

QJsonObject messageToRequestJson(const MessageData& msg, bool capVision, const UrlResolver& resolveUrl) {
    QJsonObject obj;
    obj["role"] = msg.role;

    if (msg.role == "tool") {
        obj["tool_call_id"] = msg.toolCallId;
        obj["content"]      = msg.content;
        return obj;
    }

    // DeepSeek 等推理模型在使用 tool_calls 时要求把 reasoning_content 原样带回；
    // 缺它会直接 400（Invalid tool_calls sequence）。
    if (msg.role == "assistant" && !msg.reasoning.isEmpty() && !msg.toolCallsJson.isEmpty()) {
        obj["reasoning_content"] = msg.reasoning;
    }

    if (!msg.toolCallsJson.isEmpty()) {
        QJsonDocument tcDoc = QJsonDocument::fromJson(msg.toolCallsJson.toUtf8());
        if (tcDoc.isArray()) obj["tool_calls"] = tcDoc.array();
    }

    if (msg.isMultimodal() && msg.role == "user") {
        QJsonArray contentArr;
        for (const auto& part : msg.parts) {
            if (part.type == "file") continue;
            // 活动模型不支持视觉时不发历史里的图（视觉代理下原图仅本地查看，发给文字模型会被拒）。
            if (part.type == "image_url" && !capVision) continue;
            QJsonObject p;
            p["type"] = part.type;
            if (part.type == "text") {
                p["text"] = part.text;
            } else if (part.type == "image_url") {
                const QString url = resolveUrl ? resolveUrl(part) : QString();
                // 附件被删/搬走后 url 为空，发空 url 会让本会话后续每条请求都 400，宁可少发。
                if (url.isEmpty()) continue;
                QJsonObject imgUrl;
                imgUrl["url"]  = url;
                p["image_url"] = imgUrl;
            } else if (part.type == "input_audio") {
                QJsonObject audio;
                audio["data"]    = part.data;
                audio["format"]  = part.format;
                p["input_audio"] = audio;
            }
            contentArr.append(p);
        }
        obj["content"] = contentArr.isEmpty() ? QJsonValue(msg.content) : QJsonValue(contentArr);
    } else {
        obj["content"] = msg.content;
    }

    return obj;
}

} // namespace mod::chatbot
