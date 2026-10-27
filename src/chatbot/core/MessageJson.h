// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include "chatbot/core/MessageData.h"

#include <QJsonObject>

#include <functional>

namespace mod::chatbot {

using UrlResolver = std::function<QString(const MessagePart&)>;

// Serialize one MessageData for the OpenAI-compatible request body. Kept free of
// ChatBot/AttachmentManager so the reasoning/tool_calls contract can be host-tested.
QJsonObject messageToRequestJson(const MessageData& msg, bool capVision, const UrlResolver& resolveUrl = {});

} // namespace mod::chatbot
