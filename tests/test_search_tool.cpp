// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/tools/WebSearchTool.h"
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

struct FakeCall {
    SearchHttpRequest request;
    std::function<void(int, const QByteArray&, const QString&)> reply;
};

struct FakeTransport {
    std::vector<FakeCall> calls;

    void operator()(const SearchHttpRequest& request, std::function<void(int, const QByteArray&, const QString&)> reply) {
        calls.push_back(FakeCall{request, std::move(reply)});
    }

    void answer(std::size_t index, int status, const QByteArray& body, const QString& error = QString()) {
        calls.at(index).reply(status, body, error);
    }
};

bool waitFor(const std::function<bool()>& predicate, int timeoutMs = 3000) {
    QElapsedTimer timer;
    timer.start();
    while (!predicate() && timer.elapsed() < timeoutMs) {
        QCoreApplication::processEvents(QEventLoop::AllEvents, 20);
        QThread::msleep(5);
    }
    return predicate();
}

QByteArray tavilyBody() {
    return R"({"results":[)"
           R"({"title":"T1","url":"https://a","summary":"S1","date":"2026-01-01","site_name":"A"},)"
           R"({"title":"T2","url":"https://b","snippet":"S2","content":"C2"}]})";
}

SearchConfig enabledTavily() {
    SearchConfig config;
    config.provider  = QStringLiteral("tavily");
    config.enabled   = true;
    config.tavilyKey = QStringLiteral("tvly-key");
    return config;
}

} // namespace

int main(int argc, char** argv) {
    QCoreApplication app(argc, argv);

    // ------------------------------------------------------------- config
    {
        const SearchConfig parsed = SearchConfig::fromJson(QJsonObject{
            {QStringLiteral("provider"), QStringLiteral("TAVILY")},
            {QStringLiteral("enabled"), true},
            {QStringLiteral("count"), 60},
            {QStringLiteral("needContent"), true},
            {QStringLiteral("tavilyApiKey"), QStringLiteral("k")},
            {QStringLiteral("deepseekBaseUrl"), QStringLiteral(" https://api.x/v1/ ")},
            {QStringLiteral("maxChars"), 100},
        });
        CHECK(parsed.provider == QStringLiteral("off"));
        CHECK(parsed.enabled);
        CHECK_EQ(parsed.count, 50);
        CHECK(parsed.needContent);
        CHECK_EQ(parsed.maxChars, 500);
        CHECK(parsed.deepseekBaseUrl == QStringLiteral("https://api.x"));
        CHECK(parsed.tavilyKey == QStringLiteral("k"));

        const SearchConfig minimum = SearchConfig::fromJson(QJsonObject{{QStringLiteral("count"), 0}});
        CHECK_EQ(minimum.count, 1);
        CHECK_EQ(minimum.maxChars, 6000);
        CHECK(minimum.provider == QStringLiteral("off"));

        const SearchConfig deepseek = SearchConfig::fromJson(QJsonObject{
            {QStringLiteral("provider"), QStringLiteral("deepseek")},
            {QStringLiteral("deepseekBaseUrl"), QString()},
        });
        CHECK(deepseek.deepseekBaseUrl == QStringLiteral("https://api.deepseek.com"));
        CHECK(!deepseek.configured(QString()));
        CHECK(deepseek.configured(QStringLiteral("chat-key")));
        CHECK(deepseek.effectiveKey(QStringLiteral("chat-key")) == QStringLiteral("chat-key"));

        CHECK(!enabledTavily().available(false, QString()));
        CHECK(enabledTavily().available(true, QString()));
        CHECK(enabledTavily().configured(QString()));
        CHECK(!SearchConfig{}.configured(QString()));

        const QJsonObject json = enabledTavily().toJson();
        CHECK(json.value(QStringLiteral("provider")).toString() == QStringLiteral("tavily"));
        CHECK(json.value(QStringLiteral("tavilyApiKey")).toString() == QStringLiteral("tvly-key"));
    }

    // ------------------------------------------------------ build request
    {
        CHECK(!buildSearchRequest(SearchConfig{}, QStringLiteral("q"), QString()).has_value());

        const auto tavily = buildSearchRequest(enabledTavily(), QStringLiteral("q"), QString());
        CHECK(tavily.has_value());
        if (tavily) {
            CHECK(tavily->url.toString() == QStringLiteral("https://api.tavily.com/search"));
            CHECK(tavily->authorization == QByteArray("Bearer tvly-key"));
            const QJsonObject body = QJsonDocument::fromJson(tavily->body).object();
            CHECK(body.value(QStringLiteral("query")).toString() == QStringLiteral("q"));
            CHECK(body.value(QStringLiteral("search_depth")).toString() == QStringLiteral("advanced"));
            CHECK_EQ(body.value(QStringLiteral("max_results")).toInt(), 5);
        }

        SearchConfig deepseek;
        deepseek.provider      = QStringLiteral("deepseek");
        deepseek.enabled       = true;
        deepseek.deepseekKey   = QString();
        deepseek.deepseekBaseUrl = QStringLiteral("https://api.y");
        deepseek.needContent   = true;
        const auto request = buildSearchRequest(deepseek, QStringLiteral("q2"), QStringLiteral("fallback"));
        CHECK(request.has_value());
        if (request) {
            CHECK(request->url.toString() == QStringLiteral("https://api.y/v1/tools/search"));
            CHECK(request->authorization == QByteArray("Bearer fallback"));
            const QJsonObject body = QJsonDocument::fromJson(request->body).object();
            CHECK(body.value(QStringLiteral("need_content")).toBool());
            CHECK_EQ(body.value(QStringLiteral("count")).toInt(), 5);
        }
    }

    // ----------------------------------------------------------- formatting
    {
        const QString formatted =
            formatSearchResults(QStringLiteral("pen"), QJsonDocument::fromJson(tavilyBody()).object().value("results").toArray(), true, 6000);
        CHECK(formatted.startsWith(QStringLiteral("网络搜索结果（查询: \"pen\"）：")));
        CHECK(formatted.contains(QStringLiteral("1. T1")));
        CHECK(formatted.contains(QStringLiteral("https://a")));
        CHECK(formatted.contains(QStringLiteral("2026-01-01 | A")));
        CHECK(formatted.contains(QStringLiteral("S1")));
        CHECK(formatted.contains(QStringLiteral("2. T2")));
        CHECK(formatted.contains(QStringLiteral("S2"))); // snippet fallback
        CHECK(formatted.contains(QStringLiteral("C2"))); // includeContent

        const QString withoutContent =
            formatSearchResults(QStringLiteral("pen"), QJsonDocument::fromJson(tavilyBody()).object().value("results").toArray(), false, 6000);
        CHECK(!withoutContent.contains(QStringLiteral("C2")));

        CHECK(formatSearchResults(QStringLiteral("q"), QJsonArray{}, true, 6000).isEmpty());

        const QString truncated =
            formatSearchResults(QStringLiteral("q"), QJsonDocument::fromJson(tavilyBody()).object().value("results").toArray(), false, 60);
        CHECK(truncated.contains(QStringLiteral("截断")));
    }

    // ------------------------------------------------------------- parse
    {
        const SearchOutcome ok = parseSearchResponse(enabledTavily(), tavilyBody(), QStringLiteral("pen"));
        CHECK(ok.success);
        CHECK(ok.summary == QStringLiteral("找到 2 条结果"));
        CHECK(ok.result.contains(QStringLiteral("网络搜索结果")));

        const SearchOutcome empty =
            parseSearchResponse(enabledTavily(), R"({"results":[]})", QStringLiteral("pen"));
        CHECK(empty.success);
        CHECK(empty.result == QStringLiteral("未找到相关结果"));

        const SearchOutcome bad = parseSearchResponse(enabledTavily(), "not json", QStringLiteral("pen"));
        CHECK(!bad.success);
        CHECK(bad.error == QStringLiteral("响应格式错误"));
        CHECK(bad.result.startsWith(QStringLiteral("搜索失败: ")));
    }

    // -------------------------------------------------------- tool flow
    {
        FakeTransport transport;
        WebSearchTool tool;
        tool.setTransport([&transport](const SearchHttpRequest& request, auto reply) {
            transport(request, std::move(reply));
        });

        QStringList started;
        struct Done {
            QString id;
            bool    ok = false;
            QString summary;
            QString result;
        };
        std::vector<Done> done;
        tool.setCallbacks(WebSearchTool::Callbacks{
            [&](const QString& id, const QString& query) { started.append(id + QLatin1Char(':') + query); },
            [&](const QString& id, bool ok, const QString& summary, const QString& result) {
                done.push_back(Done{id, ok, summary, result});
            },
        });

        // Rejections do not touch the transport.
        CHECK(tool.start(QStringLiteral("s0"), QStringLiteral("q"), QString()).has_value());
        tool.setConfig(enabledTavily());
        CHECK(tool.start(QStringLiteral("s0"), QStringLiteral("  "), QString()).has_value());
        CHECK(!tool.start(QStringLiteral("s0"), QStringLiteral("q"), QString()).has_value());
        CHECK(tool.start(QStringLiteral("s0"), QStringLiteral("q2"), QString()).has_value()); // duplicate id
        CHECK_EQ(transport.calls.size(), 1u);
        tool.cancelAll(QStringLiteral("reset"));
        done.clear();

        // Success flow.
        std::size_t index = transport.calls.size();
        CHECK(!tool.start(QStringLiteral("s1"), QStringLiteral("pen"), QString()).has_value());
        CHECK_EQ(started.size(), 2); // s0 (queued earlier) + s1
        CHECK_EQ(transport.calls.size(), index + 1);
        CHECK(tool.busy());
        transport.answer(index, 200, tavilyBody());
        CHECK_EQ(done.size(), 1u);
        if (!done.empty()) {
            CHECK(done[0].ok);
            CHECK(done[0].summary == QStringLiteral("找到 2 条结果"));
        }
        CHECK(!tool.busy());

        // HTTP failure without retry (401).
        done.clear();
        index = transport.calls.size();
        CHECK(!tool.start(QStringLiteral("s2"), QStringLiteral("pen"), QString()).has_value());
        transport.answer(index, 401, "{}", QStringLiteral("API Key 无效"));
        CHECK_EQ(done.size(), 1u);
        CHECK(!done.empty() && !done[0].ok);
        CHECK(!done.empty() && done[0].result.contains(QStringLiteral("API Key 无效")));

        // 5xx retries once.
        done.clear();
        tool.setRetryDelayMs(10);
        index = transport.calls.size();
        CHECK(!tool.start(QStringLiteral("s3"), QStringLiteral("pen"), QString()).has_value());
        CHECK_EQ(transport.calls.size(), index + 1);
        transport.answer(index, 500, "{}", QStringLiteral("server error"));
        CHECK(waitFor([&]() { return transport.calls.size() == index + 2; }));
        CHECK(done.empty());
        transport.answer(index + 1, 200, tavilyBody());
        CHECK_EQ(done.size(), 1u);
        CHECK(!done.empty() && done[0].ok);

        // Cancel invalidates a late transport callback.
        done.clear();
        index = transport.calls.size();
        CHECK(!tool.start(QStringLiteral("s4"), QStringLiteral("pen"), QString()).has_value());
        tool.cancelAll(QStringLiteral("用户取消"));
        CHECK_EQ(done.size(), 1u);
        transport.answer(index, 200, tavilyBody());
        CHECK_EQ(done.size(), 1u);
        CHECK(!tool.busy());

        // A scheduled retry after cancellation must not fire.
        done.clear();
        index = transport.calls.size();
        CHECK(!tool.start(QStringLiteral("s5"), QStringLiteral("pen"), QString()).has_value());
        transport.answer(index, 500, "{}", QStringLiteral("boom"));
        tool.cancelAll(QStringLiteral("中断"));
        waitFor([]() { return false; }, 50); // let the retry timer elapse
        CHECK_EQ(transport.calls.size(), index + 1);
        CHECK_EQ(done.size(), 1u);
    }

    return testSummary("search_tool");
}
