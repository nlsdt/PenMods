// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/core/MessageJson.h"
#include "test_main.h"

#include <QJsonArray>
#include <QJsonObject>

using namespace mod::chatbot;

int main() {
    MessageData assistant;
    assistant.role          = "assistant";
    assistant.content       = "answer";
    assistant.reasoning     = "think";
    assistant.toolCallsJson = R"([{"id":"c1","type":"function","function":{"name":"search","arguments":"{}"}}])";

    const QJsonObject withTools = messageToRequestJson(assistant, false);
    CHECK_EQ(withTools.value("role").toString(), QString("assistant"));
    CHECK_EQ(withTools.value("reasoning_content").toString(), QString("think"));
    CHECK(withTools.value("tool_calls").isArray());
    CHECK_EQ(withTools.value("tool_calls").toArray().size(), 1);

    MessageData plainAssistant;
    plainAssistant.role      = "assistant";
    plainAssistant.content    = "plain";
    plainAssistant.reasoning = "think";
    const QJsonObject plain = messageToRequestJson(plainAssistant, false);
    CHECK(!plain.contains("reasoning_content"));

    MessageData tool;
    tool.role       = "tool";
    tool.toolCallId = "c1";
    tool.content    = "result";
    const QJsonObject toolJson = messageToRequestJson(tool, false);
    CHECK_EQ(toolJson.value("tool_call_id").toString(), QString("c1"));
    CHECK_EQ(toolJson.value("content").toString(), QString("result"));

    MessageData image;
    image.role = "user";
    MessagePart imagePart;
    imagePart.type = "image_url";
    imagePart.url  = "https://example.invalid/a.png";
    image.parts.append(imagePart);
    const QJsonObject noVision = messageToRequestJson(image, false);
    CHECK(noVision.value("content").isString());

    return testSummary("message_json");
}
