// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include <QString>
#include <QVector>

#include <utility>

namespace mod::chatbot {

// Provider-independent stream vocabulary. Both protocols (chat_completions and
// responses) are lowered into this so the orchestrator never branches on wire
// format: text/reasoning deltas, tool-call deltas, usage, terminal events.
enum class StreamEventKind {
    Text,
    Reasoning,
    ToolCall,
    ToolStatus,
    Usage,
    Image,
    Done,
    Error,
};

struct ToolCallDelta {
    int     index = 0;
    QString id;
    QString name;      // delta, or the final name when replaceName is set
    QString arguments; // delta, or the final arguments when replaceArguments is set
    // Some providers repeat the whole call in a later event (Responses
    // output_item.done). Then the payload is authoritative, not additive.
    bool    replaceName      = false;
    bool    replaceArguments = false;
};

struct UsageDelta {
    qint64 inputTokens      = 0;
    qint64 outputTokens     = 0;
    qint64 reasoningTokens  = 0;
    qint64 cacheReadTokens  = 0;
    qint64 cacheWriteTokens = 0;
};

struct StreamEvent {
    StreamEventKind kind = StreamEventKind::Text;
    QString         text;     // Text / Reasoning / Error message
    ToolCallDelta   toolCall; // ToolCall
    QString         toolName; // ToolStatus
    QString         status;   // ToolStatus: running | done | error
    UsageDelta      usage;    // Usage
    QString         imageBase64; // Image

    static StreamEvent textDelta(QString text) {
        StreamEvent event;
        event.kind = StreamEventKind::Text;
        event.text = std::move(text);
        return event;
    }
    static StreamEvent reasoningDelta(QString text) {
        StreamEvent event;
        event.kind = StreamEventKind::Reasoning;
        event.text = std::move(text);
        return event;
    }
    static StreamEvent toolCallDelta(ToolCallDelta delta) {
        StreamEvent event;
        event.kind     = StreamEventKind::ToolCall;
        event.toolCall = std::move(delta);
        return event;
    }
    static StreamEvent toolStatus(QString toolName, QString status) {
        StreamEvent event;
        event.kind     = StreamEventKind::ToolStatus;
        event.toolName = std::move(toolName);
        event.status   = std::move(status);
        return event;
    }
    static StreamEvent usageReport(UsageDelta usage) {
        StreamEvent event;
        event.kind  = StreamEventKind::Usage;
        event.usage = usage;
        return event;
    }
    static StreamEvent image(QString base64) {
        StreamEvent event;
        event.kind        = StreamEventKind::Image;
        event.imageBase64 = std::move(base64);
        return event;
    }
    static StreamEvent done() {
        StreamEvent event;
        event.kind = StreamEventKind::Done;
        return event;
    }
    static StreamEvent error(QString message) {
        StreamEvent event;
        event.kind = StreamEventKind::Error;
        event.text = std::move(message);
        return event;
    }
};

using StreamEvents = QVector<StreamEvent>;

} // namespace mod::chatbot
