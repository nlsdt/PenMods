// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include "StreamEvent.h"
#include "chatbot/core/MessageData.h"
#include "chatbot/core/MessageJson.h"

#include <QByteArray>
#include <QJsonArray>
#include <QJsonObject>
#include <QString>
#include <QVector>

#include <memory>

namespace mod::chatbot {

struct RequestOptions {
    QString     model;
    double      temperature     = 0.7;
    bool        stream          = true;
    bool        capReasoning    = false;
    bool        capVision       = true;
    QString     reasoningEffort;
    QJsonArray  tools;          // OpenAI-style function definitions
    QJsonArray  builtinTools;   // protocol-specific tools appended verbatim
    QJsonObject extraParams;    // merged last, may override any field
    // Turns a stored attachment (localPath) into the URL the provider accepts.
    // Empty result drops the part, so a deleted attachment cannot poison a session.
    UrlResolver resolveUrl;
};

// Serializes the assembled history into OpenAI-style message objects. Shared by
// both adapters so the reasoning/tool_calls contract lives in one place.
QJsonArray serializeMessagesForRequest(
    const QVector<MessageData>& messages,
    bool                        capVision,
    const UrlResolver&          resolveUrl = {});

// Converts the wire format into StreamEvents. feed() is incremental: it buffers
// partial SSE lines, so a caller may push arbitrary network chunks. Both
// protocols share that framing; subclasses only parse one data payload.
class ProtocolAdapter {
public:
    virtual ~ProtocolAdapter() = default;

    // "chat_completions" (default) or "responses"; nullptr for unknown names.
    [[nodiscard]] static std::unique_ptr<ProtocolAdapter> create(const QString& protocol);

    [[nodiscard]] virtual QString     name() const            = 0;
    [[nodiscard]] virtual QByteArray  buildRequest(
        const QVector<MessageData>& messages,
        const RequestOptions&       options) const = 0;

    // Non-streaming body. Always ends with Done; failures end with Error + Done.
    [[nodiscard]] virtual StreamEvents parseResponse(const QByteArray& body) const = 0;

    [[nodiscard]] StreamEvents feed(const QByteArray& chunk);
    [[nodiscard]] StreamEvents finish();

    virtual void reset();

protected:
    virtual void handleData(const QString& payload, StreamEvents& out) = 0;

    // Terminal event bookkeeping: adapters call this instead of pushing Done.
    void markDone(StreamEvents& out);

    bool m_done = false;

private:
    QByteArray m_pending;
};

} // namespace mod::chatbot
