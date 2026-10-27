// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include "ProtocolAdapter.h"

#include <QHash>

namespace mod::chatbot {

// POST /responses: the Responses API stream is item-oriented. Text and reasoning
// arrive as deltas; function calls arrive as output items plus argument deltas,
// and server-side tools (web_search_call, image_generation_call, ...) report
// their own lifecycle. This adapter maps all of it onto StreamEvent, including a
// stable tool index so the caller can accumulate calls exactly like the
// chat-completions path.
class ResponsesAdapter final : public ProtocolAdapter {
public:
    [[nodiscard]] QString name() const override { return QStringLiteral("responses"); }

    [[nodiscard]] QByteArray buildRequest(
        const QVector<MessageData>& messages,
        const RequestOptions&       options) const override;

    [[nodiscard]] StreamEvents parseResponse(const QByteArray& body) const override;

    void reset() override;

protected:
    void handleData(const QString& payload, StreamEvents& out) override;

private:
    int  indexFor(const QString& itemId);
    void emitOutput(const QJsonArray& output, StreamEvents& out, bool fullPayload);

    QHash<QString, int> m_itemIndexes;
    int                 m_nextToolIndex = 0;
    bool                m_textSeen      = false;
    bool                m_reasoningSeen = false;
    bool                m_toolSeen      = false;
};

} // namespace mod::chatbot
