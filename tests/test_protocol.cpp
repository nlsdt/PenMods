// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/protocol/ChatCompletionsAdapter.h"
#include "chatbot/protocol/ProtocolAdapter.h"
#include "chatbot/protocol/ProtocolCommon.h"
#include "chatbot/protocol/ResponsesAdapter.h"
#include "test_main.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QString>

#include <cmath>

using namespace mod::chatbot;

namespace {

MessageData userMessage(const char* text) {
    MessageData msg;
    msg.messageId = QStringLiteral("u1");
    msg.role      = QStringLiteral("user");
    msg.content   = QString::fromUtf8(text);
    return msg;
}

QString textsOf(const StreamEvents& events, StreamEventKind kind) {
    QString text;
    for (const auto& event : events) {
        if (event.kind == kind) text += event.text;
    }
    return text;
}

} // namespace

int main() {
    CHECK(ProtocolAdapter::create("chat_completions") != nullptr);
    CHECK(ProtocolAdapter::create("") != nullptr);
    CHECK(ProtocolAdapter::create("responses") != nullptr);
    CHECK(ProtocolAdapter::create("weird") == nullptr);

    // ---------------------------------------------------------------- chat body
    {
        auto adapter = ProtocolAdapter::create("chat_completions");
        CHECK(adapter->name() == QStringLiteral("chat_completions"));

        MessageData assistant;
        assistant.messageId  = QStringLiteral("a1");
        assistant.role       = QStringLiteral("assistant");
        assistant.reasoning  = QStringLiteral("because");
        assistant.toolCallsJson =
            QStringLiteral(R"([{"id":"c1","type":"function","function":{"name":"search","arguments":"{}"}}])");

        RequestOptions options;
        options.model           = QStringLiteral("gpt-x");
        options.temperature     = 0.3;
        options.capReasoning    = true;
        options.reasoningEffort = QStringLiteral("high");
        options.tools.append(QJsonObject{
            {QStringLiteral("type"), QStringLiteral("function")},
            {QStringLiteral("function"),
             QJsonObject{{QStringLiteral("name"), QStringLiteral("shell")},
                         {QStringLiteral("parameters"), QJsonObject{{QStringLiteral("type"), QStringLiteral("object")}}}}},
        });
        options.extraParams.insert(QStringLiteral("max_tokens"), 512);

        const QJsonObject body =
            QJsonDocument::fromJson(adapter->buildRequest({userMessage("hi"), assistant}, options)).object();
        CHECK(body.value("model").toString() == QStringLiteral("gpt-x"));
        CHECK(qAbs(body.value("temperature").toDouble() - 0.3) < 1e-9);
        CHECK(body.value("stream").toBool());
        CHECK(body.value("stream_options").toObject().value("include_usage").toBool());
        CHECK(body.value("reasoning_effort").toString() == QStringLiteral("high"));
        CHECK(body.value("max_tokens").toInt() == 512);

        const QJsonArray messages = body.value("messages").toArray();
        CHECK(messages.size() == 2);
        CHECK(messages.at(0).toObject().value("role").toString() == QStringLiteral("user"));
        // reasoning must be echoed back for assistant tool-call messages.
        CHECK(messages.at(1).toObject().value("reasoning_content").toString() == QStringLiteral("because"));
        CHECK(messages.at(1).toObject().value("tool_calls").toArray().size() == 1);
        CHECK(body.value("tools").toArray().size() == 1);
    }

    // ------------------------------------------------------------ chat SSE
    {
        auto adapter = ProtocolAdapter::create("chat_completions");
        StreamEvents events;

        // Split a line in the middle: the adapter must buffer it.
        events += adapter->feed(QByteArray(R"(data: {"choices":[{"delta":{"reasoning_content":"thin)"));
        events += adapter->feed(QByteArray("k\"}}]}\n"));
        events += adapter->feed(QByteArray("data: {\"choices\":[{\"delta\":{\"content\":\"Hel\"}}]}\n"));
        events += adapter->feed(QByteArray("data: {\"choices\":[{\"delta\":{\"tool_calls\":[{\"index\":0,\"id\":\"c1\","
                                          "\"function\":{\"name\":\"sea\",\"arguments\":\"{\\\"q\\\":\"}}]}}]}\n"));
        events += adapter->feed(QByteArray("data: {\"choices\":[{\"delta\":{\"tool_calls\":[{\"index\":0,"
                                          "\"function\":{\"name\":\"rch\",\"arguments\":\"\\\"x\\\"}\"}}]}}]}\n"));
        events += adapter->feed(QByteArray("data: {\"choices\":[],\"usage\":{\"prompt_tokens\":10,"
                                          "\"completion_tokens\":4,\"prompt_tokens_details\":{\"cached_tokens\":6}}}\n"));
        events += adapter->feed(QByteArray("data: [DONE]\n"));

        CHECK(textsOf(events, StreamEventKind::Reasoning) == QStringLiteral("think"));
        CHECK(textsOf(events, StreamEventKind::Text) == QStringLiteral("Hel"));

        QString name, arguments;
        bool    sawId = false;
        for (const auto& event : events) {
            if (event.kind != StreamEventKind::ToolCall) continue;
            if (event.toolCall.id == QStringLiteral("c1")) sawId = true;
            name += event.toolCall.name;
            arguments += event.toolCall.arguments;
        }
        CHECK(sawId);
        CHECK(name == QStringLiteral("search"));
        CHECK(arguments == QStringLiteral(R"({"q":"x"})"));

        bool sawUsage = false;
        for (const auto& event : events) {
            if (event.kind != StreamEventKind::Usage) continue;
            sawUsage = true;
            CHECK_EQ(event.usage.inputTokens, qint64{10});
            CHECK_EQ(event.usage.outputTokens, qint64{4});
            CHECK_EQ(event.usage.cacheReadTokens, qint64{6});
        }
        CHECK(sawUsage);
        CHECK(events.last().kind == StreamEventKind::Done);

        // After Done nothing else is emitted.
        CHECK(adapter->feed(QByteArray("data: {\"choices\":[{\"delta\":{\"content\":\"x\"}}]}\n")).isEmpty());
        CHECK(adapter->finish().isEmpty());
    }

    // -------------------------------------------------------- chat non-stream
    {
        auto adapter = ProtocolAdapter::create("chat_completions");
        const QByteArray body = R"({"choices":[{"message":{"role":"assistant","content":"answer",)"
                                R"("reasoning_content":"why","tool_calls":[{"id":"c9","type":"function",)"
                                R"("function":{"name":"shell","arguments":"{\"cmd\":\"ls\"}"}}]}}],)"
                                R"("usage":{"input_tokens":7,"output_tokens":3,)"
                                R"("output_tokens_details":{"reasoning_tokens":2}}})";
        const StreamEvents events = adapter->parseResponse(body);
        CHECK(textsOf(events, StreamEventKind::Text) == QStringLiteral("answer"));
        CHECK(textsOf(events, StreamEventKind::Reasoning) == QStringLiteral("why"));

        int tools = 0;
        qint64 reasoningTokens = 0;
        for (const auto& event : events) {
            if (event.kind == StreamEventKind::ToolCall) {
                ++tools;
                CHECK(event.toolCall.id == QStringLiteral("c9"));
                CHECK(event.toolCall.name == QStringLiteral("shell"));
                CHECK(event.toolCall.replaceArguments);
                CHECK(event.toolCall.arguments == QStringLiteral(R"({"cmd":"ls"})"));
            }
            if (event.kind == StreamEventKind::Usage) reasoningTokens = event.usage.reasoningTokens;
        }
        CHECK_EQ(tools, 1);
        CHECK_EQ(reasoningTokens, qint64{2});
        CHECK(events.last().kind == StreamEventKind::Done);
    }

    // ------------------------------------------------------------- chat error
    {
        auto adapter = ProtocolAdapter::create("chat_completions");
        const StreamEvents events = adapter->parseResponse(R"({"error":{"message":"bad key"}})");
        CHECK_EQ(events.size(), 2);
        CHECK(events.first().kind == StreamEventKind::Error);
        CHECK(events.first().text.contains(QStringLiteral("bad key")));
        CHECK(events.last().kind == StreamEventKind::Done);
    }

    // ----------------------------------------------------------- responses body
    {
        auto adapter = ProtocolAdapter::create("responses");
        CHECK(adapter->name() == QStringLiteral("responses"));

        MessageData assistant;
        assistant.role          = QStringLiteral("assistant");
        assistant.toolCallsJson =
            QStringLiteral(R"([{"id":"c1","type":"function","function":{"name":"search","arguments":"{}"}}])");

        MessageData tool;
        tool.role       = QStringLiteral("tool");
        tool.toolCallId = QStringLiteral("c1");
        tool.content    = QStringLiteral("result");

        MessageData image = userMessage("look");
        MessagePart textPart;
        textPart.type = QStringLiteral("text");
        textPart.text = QStringLiteral("look");
        MessagePart part;
        part.type = QStringLiteral("image_url");
        part.url  = QStringLiteral("https://example.com/a.png");
        image.parts.append(textPart);
        image.parts.append(part);

        RequestOptions options;
        options.model      = QStringLiteral("o4");
        options.resolveUrl = [](const MessagePart& p) { return p.url; };
        options.capReasoning    = true;
        options.reasoningEffort = QStringLiteral("medium");
        options.tools.append(QJsonObject{
            {QStringLiteral("type"), QStringLiteral("function")},
            {QStringLiteral("function"),
             QJsonObject{{QStringLiteral("name"), QStringLiteral("shell")},
                         {QStringLiteral("description"), QStringLiteral("run")},
                         {QStringLiteral("parameters"), QJsonObject{{QStringLiteral("type"), QStringLiteral("object")}}}}},
        });
        options.builtinTools.append(QJsonObject{{QStringLiteral("type"), QStringLiteral("web_search")}});

        const QJsonObject body =
            QJsonDocument::fromJson(adapter->buildRequest({image, assistant, tool}, options)).object();
        CHECK(body.value("model").toString() == QStringLiteral("o4"));
        CHECK(body.value("reasoning").toObject().value("summary").toString() == QStringLiteral("auto"));
        CHECK(body.value("reasoning").toObject().value("effort").toString() == QStringLiteral("medium"));

        const QJsonArray input = body.value("input").toArray();
        CHECK_EQ(input.size(), 3);
        if (input.size() == 3) {
            CHECK(input.at(0).toObject().value("type").toString() == QStringLiteral("message"));
            const QJsonArray content = input.at(0).toObject().value("content").toArray();
            CHECK_EQ(content.size(), 2);
            CHECK(content.at(0).toObject().value("type").toString() == QStringLiteral("input_text"));
            CHECK(content.at(1).toObject().value("type").toString() == QStringLiteral("input_image"));
            CHECK(input.at(1).toObject().value("type").toString() == QStringLiteral("function_call"));
            CHECK(input.at(1).toObject().value("call_id").toString() == QStringLiteral("c1"));
            CHECK(input.at(2).toObject().value("type").toString() == QStringLiteral("function_call_output"));
            CHECK(input.at(2).toObject().value("output").toString() == QStringLiteral("result"));
        }

        const QJsonArray tools = body.value("tools").toArray();
        CHECK_EQ(tools.size(), 2);
        if (tools.size() == 2) {
            // Responses tools are flat, not nested under "function".
            CHECK(tools.at(0).toObject().value("name").toString() == QStringLiteral("shell"));
            CHECK(tools.at(0).toObject().contains(QStringLiteral("parameters")));
            CHECK(tools.at(1).toObject().value("type").toString() == QStringLiteral("web_search"));
        }
    }

    // -------------------------------------------------------- responses SSE
    {
        auto adapter = ProtocolAdapter::create("responses");
        StreamEvents events;
        events += adapter->feed(QByteArray("event: response.reasoning_summary_text.delta\n"
                                           "data: {\"type\":\"response.reasoning_summary_text.delta\",\"delta\":\"plan\"}\n\n"));
        events += adapter->feed(QByteArray("event: response.output_text.delta\n"
                                           "data: {\"type\":\"response.output_text.delta\",\"delta\":\"Hi\"}\n\n"));
        events += adapter->feed(QByteArray(
            "data: {\"type\":\"response.output_item.added\",\"item\":{\"id\":\"i1\",\"type\":\"function_call\","
            "\"call_id\":\"c1\",\"name\":\"search\",\"arguments\":\"\"}}\n\n"));
        events += adapter->feed(QByteArray(
            "data: {\"type\":\"response.function_call_arguments.delta\",\"item_id\":\"i1\",\"delta\":\"{\\\"q\\\":1}\"}\n\n"));
        events += adapter->feed(QByteArray(
            "data: {\"type\":\"response.function_call_arguments.delta\",\"item_id\":\"i1\",\"delta\":\"\"}\n\n"));
        events += adapter->feed(QByteArray(
            "data: {\"type\":\"response.completed\",\"response\":{\"status\":\"completed\",\"usage\":"
            "{\"input_tokens\":5,\"output_tokens\":2},\"output\":[]}}\n\n"));

        CHECK(textsOf(events, StreamEventKind::Reasoning) == QStringLiteral("plan"));
        CHECK(textsOf(events, StreamEventKind::Text) == QStringLiteral("Hi"));

        int tools = 0, uniqueIndexes = 0;
        QString arguments;
        int firstIndex = -1;
        for (const auto& event : events) {
            if (event.kind != StreamEventKind::ToolCall) continue;
            ++tools;
            arguments += event.toolCall.arguments;
            if (firstIndex < 0) firstIndex = event.toolCall.index;
            if (event.toolCall.index == firstIndex) ++uniqueIndexes;
        }
        CHECK_EQ(tools, 3);
        CHECK_EQ(uniqueIndexes, 3);
        CHECK(arguments == QStringLiteral(R"({"q":1})"));

        bool sawUsage = false;
        for (const auto& event : events) {
            if (event.kind == StreamEventKind::Usage) {
                sawUsage = true;
                CHECK_EQ(event.usage.inputTokens, qint64{5});
            }
        }
        CHECK(sawUsage);
        CHECK(events.last().kind == StreamEventKind::Done);
    }

    // ------------------------------------------ responses completed fallback
    {
        auto adapter = ProtocolAdapter::create("responses");
        StreamEvents events;
        events += adapter->feed(QByteArray(
            "data: {\"type\":\"response.completed\",\"response\":{\"status\":\"completed\",\"output\":["
            "{\"type\":\"reasoning\",\"summary\":[{\"type\":\"summary_text\",\"text\":\"why\"}]},"
            "{\"type\":\"message\",\"content\":[{\"type\":\"output_text\",\"text\":\"final\"}]},"
            "{\"type\":\"function_call\",\"id\":\"i2\",\"call_id\":\"c2\",\"name\":\"shell\",\"arguments\":\"{}\"},"
            "{\"type\":\"image_generation_call\",\"result\":\"QUJD\"}]}}\n\n"));

        CHECK(textsOf(events, StreamEventKind::Reasoning) == QStringLiteral("why"));
        CHECK(textsOf(events, StreamEventKind::Text) == QStringLiteral("final"));

        int tools = 0, images = 0;
        for (const auto& event : events) {
            if (event.kind == StreamEventKind::ToolCall) {
                ++tools;
                CHECK(event.toolCall.id == QStringLiteral("c2"));
                CHECK(event.toolCall.name == QStringLiteral("shell"));
                CHECK(event.toolCall.replaceArguments);
            }
            if (event.kind == StreamEventKind::Image) {
                ++images;
                CHECK(event.imageBase64 == QStringLiteral("QUJD"));
            }
        }
        CHECK_EQ(tools, 1);
        CHECK_EQ(images, 1);
        CHECK(events.last().kind == StreamEventKind::Done);
    }

    // -------------------------------------------------- responses server tool
    {
        auto adapter = ProtocolAdapter::create("responses");
        StreamEvents events;
        events += adapter->feed(QByteArray(
            "data: {\"type\":\"response.web_search_call.in_progress\",\"item_id\":\"ws1\"}\n\n"));
        events += adapter->feed(QByteArray(
            "data: {\"type\":\"response.web_search_call.completed\",\"item_id\":\"ws1\"}\n\n"));
        int running = 0, done = 0;
        for (const auto& event : events) {
            if (event.kind != StreamEventKind::ToolStatus) continue;
            if (event.toolName != QStringLiteral("web_search_call")) continue;
            if (event.status == QStringLiteral("running")) ++running;
            if (event.status == QStringLiteral("done")) ++done;
        }
        CHECK_EQ(running, 1);
        CHECK_EQ(done, 1);
    }

    // ------------------------------------------------------- responses error
    {
        auto adapter = ProtocolAdapter::create("responses");
        StreamEvents events;
        events += adapter->feed(QByteArray(
            "data: {\"type\":\"response.failed\",\"response\":{\"error\":{\"message\":\"boom\"}}}\n\n"));
        CHECK_EQ(events.size(), 2);
        CHECK(events.first().kind == StreamEventKind::Error);
        CHECK(events.first().text.contains(QStringLiteral("boom")));
        CHECK(events.last().kind == StreamEventKind::Done);
    }

    // --------------------------------------- responses non-stream + malformed
    {
        auto adapter = ProtocolAdapter::create("responses");
        const StreamEvents events = adapter->parseResponse(
            R"({"output":[{"type":"reasoning","content":[{"type":"reasoning_text","text":"raw"}]},)"
            R"({"type":"message","content":[{"type":"output_text","text":"done"}]},)"
            R"({"type":"function_call","call_id":"c3","name":"shell","arguments":"{}"}],)"
            R"("usage":{"input_tokens":9,"output_tokens":1}})");
        CHECK(textsOf(events, StreamEventKind::Reasoning) == QStringLiteral("raw"));
        CHECK(textsOf(events, StreamEventKind::Text) == QStringLiteral("done"));
        int tools = 0;
        for (const auto& event : events) {
            if (event.kind == StreamEventKind::ToolCall) ++tools;
        }
        CHECK_EQ(tools, 1);
        CHECK(events.last().kind == StreamEventKind::Done);

        const StreamEvents bad = adapter->parseResponse("not json");
        CHECK(bad.size() == 2);
        CHECK(bad.first().kind == StreamEventKind::Error);
    }

    // ------------------------------------------------ finish without [DONE]
    {
        auto adapter = ProtocolAdapter::create("chat_completions");
        StreamEvents events = adapter->feed(QByteArray("data: {\"choices\":[{\"delta\":{\"content\":\"tail\"}}]}"));
        CHECK(events.isEmpty());
        events = adapter->finish();
        CHECK(textsOf(events, StreamEventKind::Text) == QStringLiteral("tail"));
        CHECK(events.last().kind == StreamEventKind::Done);
    }

    return testSummary("protocol");
}
