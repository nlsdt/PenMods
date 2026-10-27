// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include "chatbot/core/MessageData.h"

#include <QString>
#include <QVector>

namespace mod::chatbot {

struct ContextOptions {
    QString systemPrompt;
    // 0 disables trimming. Otherwise history is trimmed whole-turn until the
    // estimated request fits maxContextTokens - reserveOutputTokens.
    int  maxContextTokens    = 0;
    int  reserveOutputTokens = 0;
};

struct AssembledContext {
    QVector<MessageData> messages; // system (optional) + trimmed history + user
    int                  estimatedTokens = 0;
    int                  droppedMessages = 0;
};

// Builds the exact message list a request will carry. Pure function: no global
// state, no network, host-testable.
class ContextAssembler {
public:
    [[nodiscard]] static AssembledContext assemble(
        const QVector<MessageData>& history,
        const MessageData&          userMessage,
        const ContextOptions&       options = {});

    // Same rules without appending a new user message. Used when a tool batch
    // finishes and the model must continue from the tool results.
    [[nodiscard]] static AssembledContext assembleContinuation(
        const QVector<MessageData>& history,
        const ContextOptions&       options = {});

    // Rebuilds the tool_calls/tool-result pairing: drops orphan results, drops
    // duplicate/empty call ids, and inserts a placeholder result for calls that
    // never got one. The old backend did this on the serialized JSON right before
    // sending; doing it on the model keeps the same guarantee for both protocols.
    static void normalizeToolSequence(QVector<MessageData>& messages);
};

// Result text used when a tool call has no recorded result (cancelled, denied,
// or persisted without one).
QString pendingToolResultText();

} // namespace mod::chatbot
