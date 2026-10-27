// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/engine/ChatEngine.h"
#include "test_main.h"

#include <QCoreApplication>
#include <QElapsedTimer>
#include <QEventLoop>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QString>
#include <QThread>

#include <functional>
#include <vector>

using namespace mod::chatbot;

namespace {

struct FakeTransport {
    bool                                                           has = false;
    HttpRequest                                                    request;
    std::function<void(const QByteArray&)>                         onData;
    std::function<void(int, const QByteArray&, const QString&)>    onDone;
    bool                                                           cancelled = false;

    HttpCancel operator()(
        const HttpRequest&                                            req,
        std::function<void(const QByteArray&)>                        data,
        std::function<void(int, const QByteArray&, const QString&)>   done) {
        has      = true;
        request  = req;
        onData   = std::move(data);
        onDone   = std::move(done);
        return [this]() { cancelled = true; };
    }

    void feed(const char* bytes) {
        if (onData) onData(QByteArray(bytes));
    }
    void complete(int status = 200, const QByteArray& body = {}, const QString& error = QString()) {
        if (onDone) onDone(status, body, error);
    }
};

ChatRequest streamingRequest() {
    ChatRequest request;
    request.endpoint = QStringLiteral("https://api.example/v1/chat/completions");
    request.apiKey   = QStringLiteral("sk-test");
    request.options.model = QStringLiteral("deepseek-chat");
    request.options.stream = true;

    MessageData user;
    user.role    = QStringLiteral("user");
    user.content = QStringLiteral("hi");
    request.messages.append(user);
    return request;
}

struct Capture {
    QStringList                   starts;
    QString                       text;
    QString                       reasoning;
    QVector<UsageDelta>           usages;
    QStringList                   toolStatuses;
    bool                          called = false;
    ChatResult                    result;
};

ChatCallbacks makeCallbacks(Capture* capture) {
    ChatCallbacks callbacks;
    callbacks.streamStart = [capture](const QString& id) { capture->starts.append(id); };
    callbacks.textDelta   = [capture](const QString& text) { capture->text += text; };
    callbacks.reasoningDelta = [capture](const QString& text) { capture->reasoning += text; };
    callbacks.usage          = [capture](const UsageDelta& usage) { capture->usages.append(usage); };
    callbacks.toolStatus     = [capture](const QString& name, const QString& status) {
        capture->toolStatuses.append(name + QLatin1Char(':') + status);
    };
    callbacks.finished = [capture](const ChatResult& result) {
        capture->called = true;
        capture->result = result;
    };
    return callbacks;
}

} // namespace

int main(int argc, char** argv) {
    QCoreApplication app(argc, argv);

    // ------------------------------------------------------- streaming chat
    {
        FakeTransport fake;
        ChatEngine    engine;
        engine.setTransport([&fake](const HttpRequest& request, auto data, auto done) {
            return fake(request, std::move(data), std::move(done));
        });

        Capture capture;
        engine.setCallbacks(makeCallbacks(&capture));

        CHECK(!engine.busy());
        CHECK(engine.send(streamingRequest()));
        CHECK(engine.busy());
        CHECK(!engine.responseMessageId().isEmpty());
        CHECK(fake.has);
        CHECK(fake.request.url.toString() == QStringLiteral("https://api.example/v1/chat/completions"));
        CHECK(fake.request.authorization == QByteArray("Bearer sk-test"));

        const QJsonObject body = QJsonDocument::fromJson(fake.request.body).object();
        CHECK(body.value(QStringLiteral("model")).toString() == QStringLiteral("deepseek-chat"));
        CHECK(body.value(QStringLiteral("stream")).toBool());

        // A second send while busy is rejected and does not disturb the first.
        CHECK(!engine.send(streamingRequest()));

        fake.feed(R"(data: {"choices":[{"delta":{"reasoning_content":"think"}}]})" "\n");
        fake.feed(R"(data: {"choices":[{"delta":{"content":"Hel"}}]})" "\n");
        fake.feed(R"(data: {"choices":[{"delta":{"content":"lo"}}]})" "\n");
        fake.feed(
            R"(data: {"choices":[{"delta":{"tool_calls":[{"index":0,"id":"c1","function":{"name":"shell_exec","arguments":"{\"command\":"}}]}}]})"
            "\n");
        fake.feed(
            R"(data: {"choices":[{"delta":{"tool_calls":[{"index":0,"function":{"name":"","arguments":"\"ls\"}"}}]}}]})"
            "\n");
        fake.feed(R"(data: {"choices":[],"usage":{"prompt_tokens":9,"completion_tokens":3}})" "\n");
        CHECK(!capture.called);

        fake.complete();
        CHECK(capture.called);
        CHECK(!engine.busy());
        CHECK_EQ(capture.starts.size(), 1);
        CHECK(capture.text == QStringLiteral("Hello"));
        CHECK(capture.reasoning == QStringLiteral("think"));
        CHECK_EQ(capture.usages.size(), 1);
        CHECK(!capture.result.failed);
        CHECK(!capture.result.cancelled);
        CHECK(capture.result.messageId == engine.responseMessageId());
        CHECK(capture.result.content == QStringLiteral("Hello"));
        CHECK(capture.result.reasoning == QStringLiteral("think"));
        CHECK_EQ(capture.result.usage.inputTokens, qint64{9});
        CHECK_EQ(capture.result.usage.outputTokens, qint64{3});

        const QJsonArray tools = QJsonDocument::fromJson(capture.result.toolCallsJson.toUtf8()).array();
        CHECK_EQ(tools.size(), 1);
        if (tools.size() == 1) {
            const QJsonObject tool = tools.at(0).toObject();
            CHECK(tool.value(QStringLiteral("id")).toString() == QStringLiteral("c1"));
            CHECK(tool.value(QStringLiteral("function")).toObject().value(QStringLiteral("name")).toString()
                  == QStringLiteral("shell_exec"));
            CHECK(tool.value(QStringLiteral("function")).toObject().value(QStringLiteral("arguments")).toString()
                  == QStringLiteral(R"({"command":"ls"})"));
        }
    }

    // ----------------------------------------------------- non-stream chat
    {
        FakeTransport fake;
        ChatEngine    engine;
        engine.setTransport([&fake](const HttpRequest& request, auto data, auto done) {
            return fake(request, std::move(data), std::move(done));
        });

        Capture capture;
        engine.setCallbacks(makeCallbacks(&capture));

        ChatRequest request = streamingRequest();
        request.options.stream = false;
        CHECK(engine.send(request));
        CHECK(!QJsonDocument::fromJson(fake.request.body).object().value(QStringLiteral("stream")).toBool());

        fake.complete(
            200,
            R"({"choices":[{"message":{"role":"assistant","content":"answer","reasoning_content":"why"}}],)"
            R"("usage":{"input_tokens":4,"output_tokens":2}})");
        CHECK(capture.called);
        CHECK(!capture.result.failed);
        CHECK(capture.result.content == QStringLiteral("answer"));
        CHECK(capture.result.reasoning == QStringLiteral("why"));
        CHECK(capture.text == QStringLiteral("answer")); // textDelta fired for non-stream too
        CHECK_EQ(capture.result.usage.inputTokens, qint64{4});
    }

    // ------------------------------------------------------------- errors
    {
        FakeTransport fake;
        ChatEngine    engine;
        engine.setTransport([&fake](const HttpRequest& request, auto data, auto done) {
            return fake(request, std::move(data), std::move(done));
        });

        Capture capture;
        engine.setCallbacks(makeCallbacks(&capture));
        CHECK(engine.send(streamingRequest()));
        fake.complete(400, R"({"error":{"message":"Invalid tool_calls sequence"}})");
        CHECK(capture.called);
        CHECK(capture.result.failed);
        CHECK(capture.result.error.contains(QStringLiteral("HTTP 400")));
        CHECK(capture.result.error.contains(QStringLiteral("Invalid tool_calls")));
        CHECK(capture.result.toolCallsJson.isEmpty());
        CHECK(!engine.busy());

        // Network-level failure.
        capture = Capture{};
        engine.setCallbacks(makeCallbacks(&capture));
        CHECK(engine.send(streamingRequest()));
        fake.complete(0, {}, QStringLiteral("timeout"));
        CHECK(capture.called);
        CHECK(capture.result.failed);
        CHECK(capture.result.error.contains(QStringLiteral("timeout")));

        // Adapter-level error event inside a 200 stream still fails the request.
        capture = Capture{};
        engine.setCallbacks(makeCallbacks(&capture));
        CHECK(engine.send(streamingRequest()));
        fake.feed(R"(data: {"error":{"message":"bad key"}})" "\n");
        CHECK(capture.called);
        CHECK(capture.result.failed);
        CHECK(capture.result.error.contains(QStringLiteral("bad key")));
    }

    // ------------------------------------------------------------ cancel
    {
        FakeTransport fake;
        ChatEngine    engine;
        engine.setTransport([&fake](const HttpRequest& request, auto data, auto done) {
            return fake(request, std::move(data), std::move(done));
        });

        Capture capture;
        engine.setCallbacks(makeCallbacks(&capture));
        CHECK(engine.send(streamingRequest()));
        fake.feed(R"(data: {"choices":[{"delta":{"content":"part"}}]})" "\n");

        engine.cancel();
        CHECK(fake.cancelled);
        CHECK(capture.called);
        CHECK(capture.result.cancelled);
        CHECK(!capture.result.failed);
        CHECK(capture.result.content == QStringLiteral("part"));
        CHECK(!engine.busy());

        // Late transport callbacks after cancellation are ignored.
        fake.feed(R"(data: {"choices":[{"delta":{"content":"late"}}]})" "\n");
        fake.complete();
        CHECK(capture.result.content == QStringLiteral("part"));
    }

    // ------------------------------------------------- unknown protocol
    {
        FakeTransport fake;
        ChatEngine    engine;
        engine.setTransport([&fake](const HttpRequest& request, auto data, auto done) {
            return fake(request, std::move(data), std::move(done));
        });

        Capture capture;
        engine.setCallbacks(makeCallbacks(&capture));
        ChatRequest request = streamingRequest();
        request.protocol    = QStringLiteral("bogus");
        CHECK(!engine.send(request));
        CHECK(capture.called);
        CHECK(capture.result.failed);
        CHECK(capture.result.error.contains(QStringLiteral("协议")));
        CHECK(!fake.has);
        CHECK(!engine.busy());
    }

    // ------------------------------------------------ responses server tools
    {
        FakeTransport fake;
        ChatEngine    engine;
        engine.setTransport([&fake](const HttpRequest& request, auto data, auto done) {
            return fake(request, std::move(data), std::move(done));
        });

        Capture capture;
        engine.setCallbacks(makeCallbacks(&capture));
        ChatRequest request = streamingRequest();
        request.protocol    = QStringLiteral("responses");
        CHECK(engine.send(request));

        fake.feed(
            R"(data: {"type":"response.web_search_call.in_progress","item_id":"ws1"})" "\n");
        fake.feed(
            R"(data: {"type":"response.web_search_call.completed","item_id":"ws1"})" "\n");
        fake.feed(
            R"(data: {"type":"response.output_text.delta","delta":"ok"})" "\n");
        fake.feed(
            R"(data: {"type":"response.completed","response":{"status":"completed","usage":{"input_tokens":2,"output_tokens":1},"output":[]}})"
            "\n");

        CHECK(capture.called);
        CHECK(capture.result.content == QStringLiteral("ok"));
        CHECK_EQ(capture.toolStatuses.size(), 2);
        if (capture.toolStatuses.size() == 2) {
            CHECK(capture.toolStatuses[0] == QStringLiteral("web_search_call:running"));
            CHECK(capture.toolStatuses[1] == QStringLiteral("web_search_call:done"));
        }
    }

    // ---------------------------------------------------------- idle timeout
    {
        FakeTransport fake;
        ChatEngine    engine;
        engine.setTransport([&fake](const HttpRequest& request, auto data, auto done) {
            return fake(request, std::move(data), std::move(done));
        });
        engine.setIdleTimeoutMs(50);

        Capture capture;
        engine.setCallbacks(makeCallbacks(&capture));
        CHECK(engine.send(streamingRequest()));
        CHECK(fake.has);
        CHECK(!capture.called);

        QElapsedTimer timer;
        timer.start();
        while (!capture.called && timer.elapsed() < 2000) {
            QCoreApplication::processEvents(QEventLoop::AllEvents, 10);
            QThread::msleep(5);
        }
        CHECK(capture.called);
        CHECK(capture.result.failed);
        CHECK(capture.result.error.contains(QStringLiteral("超时")));
        CHECK(fake.cancelled);
        CHECK(!engine.busy());
    }

    return testSummary("chat_engine");
}
