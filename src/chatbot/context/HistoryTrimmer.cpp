// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/context/HistoryTrimmer.h"

#include <QtGlobal>

#include <cmath>

namespace mod::chatbot {

namespace {

bool isCjk(QChar ch) {
    const ushort code = ch.unicode();
    return (code >= 0x2E80 && code <= 0x9FFF) || (code >= 0x3000 && code <= 0x303F)
           || (code >= 0xF900 && code <= 0xFAFF) || (code >= 0xFF00 && code <= 0xFFEF);
}

int tokensForText(const QString& text) {
    if (text.isEmpty()) return 0;

    int cjk   = 0;
    int other = 0;
    for (const QChar ch : text) {
        if (isCjk(ch)) ++cjk;
        else ++other;
    }
    return static_cast<int>(std::ceil(cjk / 1.5 + other / 4.0)) + 1;
}

} // namespace

int estimateTokens(const QString& text) { return tokensForText(text); }

int estimateTokens(const MessageData& message) {
    int tokens = 4; // 角色与分隔符的固定开销
    tokens += tokensForText(message.content);
    tokens += tokensForText(message.reasoning);
    tokens += tokensForText(message.toolCallsJson);

    for (const auto& part : message.parts) {
        if (part.type == QLatin1String("text")) {
            tokens += tokensForText(part.text);
        } else if (part.type == QLatin1String("image_url")) {
            // 图片按固定开销估算：data URL 比远端 URL 贵得多。
            tokens += part.url.startsWith(QLatin1String("data:")) ? 1024 : 128;
        } else if (part.type == QLatin1String("input_audio")) {
            tokens += 1024;
        } else if (part.type == QLatin1String("file")) {
            tokens += 128;
        }
    }
    return tokens;
}

int estimateTokens(const QVector<MessageData>& messages) {
    int total = 0;
    for (const auto& message : messages) total += estimateTokens(message);
    return total;
}

void trimHistoryToBudget(QVector<MessageData>& messages, int budgetTokens) {
    if (budgetTokens <= 0) return;

    int total = estimateTokens(messages);
    while (total > budgetTokens) {
        int firstUser = 0;
        while (firstUser < messages.size() && messages[firstUser].role != QLatin1String("user")) ++firstUser;
        if (firstUser >= messages.size()) return;

        int nextUser = firstUser + 1;
        while (nextUser < messages.size() && messages[nextUser].role != QLatin1String("user")) ++nextUser;
        if (nextUser >= messages.size()) return; // 只剩最后一轮，不能再删

        messages.remove(0, nextUser);
        total = estimateTokens(messages);
    }
}

} // namespace mod::chatbot
