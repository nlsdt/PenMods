// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include "ProtocolAdapter.h"

namespace mod::chatbot {

// POST /chat/completions: OpenAI-compatible SSE. Tool calls arrive as
// choices[0].delta.tool_calls[] with index/id/function.{name,arguments} deltas.
class ChatCompletionsAdapter final : public ProtocolAdapter {
public:
    [[nodiscard]] QString name() const override { return QStringLiteral("chat_completions"); }

    [[nodiscard]] QByteArray buildRequest(
        const QVector<MessageData>& messages,
        const RequestOptions&       options) const override;

    [[nodiscard]] StreamEvents parseResponse(const QByteArray& body) const override;

protected:
    void handleData(const QString& payload, StreamEvents& out) override;
};

} // namespace mod::chatbot
