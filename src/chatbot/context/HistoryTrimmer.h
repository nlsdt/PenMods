// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include "chatbot/core/MessageData.h"

namespace mod::chatbot {

// 粗略 token 估算：CJK 字符 / 1.5 + 其他字符 / 4。只用于预算量级判断。
int estimateTokens(const QString& text);
int estimateTokens(const MessageData& message);
int estimateTokens(const QVector<MessageData>& messages);

// 超预算时从最旧的“整轮”开始丢弃：一个 turn = 一条 user + 其后的
// assistant / tool 消息，保证 tool_calls 与结果、reasoning 不被拆开。
void trimHistoryToBudget(QVector<MessageData>& messages, int budgetTokens);

} // namespace mod::chatbot
