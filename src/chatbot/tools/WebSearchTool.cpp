// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "WebSearchTool.h"

#include <QHash>
#include <QJsonDocument>
#include <QJsonValue>
#include <QStringList>
#include <QTimer>

#include <algorithm>

namespace mod::chatbot {

namespace {

int clamped(int value, int minimum, int maximum) { return std::clamp(value, minimum, maximum); }

QString normalizedBaseUrl(const QString& input) {
    QString base = input.trimmed();
    while (base.endsWith(QLatin1Char('/'))) base.chop(1);
    if (base.endsWith(QLatin1String("/v1"))) base.chop(3);
    return base.isEmpty() ? QStringLiteral("https://api.deepseek.com") : base;
}

struct Pending {
    QString query;
    int     attempt = 0;
};

} // namespace

SearchConfig SearchConfig::fromJson(const QJsonObject& object) {
    SearchConfig config;

    const QString provider = object.value(QStringLiteral("provider")).toString(QStringLiteral("off"));
    if (provider == QLatin1String("tavily") || provider == QLatin1String("deepseek")) {
        config.provider = provider;
    } else {
        config.provider = QStringLiteral("off");
    }

    config.enabled     = object.value(QStringLiteral("enabled")).toBool(false);
    config.count       = clamped(object.value(QStringLiteral("count")).toInt(5), 1, 50);
    config.needContent = object.value(QStringLiteral("needContent")).toBool(false);
    config.tavilyKey   = object.value(QStringLiteral("tavilyApiKey")).toString();
    config.deepseekKey = object.value(QStringLiteral("deepseekApiKey")).toString();
    config.deepseekBaseUrl =
        normalizedBaseUrl(object.value(QStringLiteral("deepseekBaseUrl")).toString());

    const QString depth = object.value(QStringLiteral("tavilySearchDepth")).toString();
    if (!depth.isEmpty()) config.tavilyDepth = depth;

    const QJsonValue maxChars = object.value(QStringLiteral("maxChars"));
    if (!maxChars.isUndefined()) config.maxChars = clamped(maxChars.toInt(6000), 500, 20000);
    return config;
}

QJsonObject SearchConfig::toJson() const {
    return QJsonObject{
        {QStringLiteral("provider"), provider},
        {QStringLiteral("enabled"), enabled},
        {QStringLiteral("count"), count},
        {QStringLiteral("needContent"), needContent},
        {QStringLiteral("tavilyApiKey"), tavilyKey},
        {QStringLiteral("deepseekApiKey"), deepseekKey},
        {QStringLiteral("deepseekBaseUrl"), deepseekBaseUrl},
    };
}

QString SearchConfig::effectiveKey(const QString& fallbackApiKey) const {
    if (provider == QLatin1String("deepseek")) {
        return deepseekKey.isEmpty() ? fallbackApiKey : deepseekKey;
    }
    return tavilyKey;
}

bool SearchConfig::configured(const QString& fallbackApiKey) const {
    if (provider == QLatin1String("off")) return false;
    return !effectiveKey(fallbackApiKey).isEmpty();
}

bool SearchConfig::available(bool capToolCall, const QString& fallbackApiKey) const {
    return capToolCall && enabled && configured(fallbackApiKey);
}

std::optional<SearchHttpRequest>
buildSearchRequest(const SearchConfig& config, const QString& query, const QString& fallbackApiKey) {
    if (!config.configured(fallbackApiKey)) return std::nullopt;

    const QString key = config.effectiveKey(fallbackApiKey);
    SearchHttpRequest request;
    request.authorization = "Bearer " + key.toUtf8();

    if (config.provider == QLatin1String("tavily")) {
        request.url = QUrl(QStringLiteral("https://api.tavily.com/search"));
        QJsonObject body{
            {QStringLiteral("query"), query},
            {QStringLiteral("search_depth"), config.tavilyDepth},
            {QStringLiteral("max_results"), config.count},
        };
        request.body = QJsonDocument(body).toJson(QJsonDocument::Compact);
    } else {
        request.url = QUrl(config.deepseekBaseUrl + QStringLiteral("/v1/tools/search"));
        QJsonObject body{
            {QStringLiteral("query"), query},
            {QStringLiteral("count"), config.count},
            {QStringLiteral("need_content"), config.needContent},
        };
        request.body = QJsonDocument(body).toJson(QJsonDocument::Compact);
    }
    return request;
}

QString formatSearchResults(
    const QString&    query,
    const QJsonArray& results,
    bool              includeContent,
    int               maxChars) {
    QString   formatted = QStringLiteral("网络搜索结果（查询: \"%1\"）：\n\n").arg(query);
    int       count     = 0;
    const int perItemContentLimit = 1500;

    for (const auto& value : results) {
        const QJsonObject result = value.toObject();

        const QString title = result.value(QStringLiteral("title")).toString();
        const QString url   = result.value(QStringLiteral("url")).toString();

        QString summary = result.value(QStringLiteral("summary")).toString();
        if (summary.isEmpty()) summary = result.value(QStringLiteral("snippet")).toString();
        if (summary.isEmpty()) summary = result.value(QStringLiteral("content")).toString();
        if (summary.isEmpty() && url.isEmpty()) continue;

        QStringList meta;
        QString     date = result.value(QStringLiteral("date")).toString();
        if (date.isEmpty()) date = result.value(QStringLiteral("published_date")).toString();
        if (!date.isEmpty()) meta.append(date);
        const QString site = result.value(QStringLiteral("site_name")).toString();
        if (!site.isEmpty()) meta.append(site);

        QString item = QStringLiteral("%1. %2\n   %3\n")
                           .arg(++count)
                           .arg(title.isEmpty() ? url : title, url);
        if (!meta.isEmpty()) item += QStringLiteral("   ") + meta.join(QStringLiteral(" | ")) + QLatin1Char('\n');

        if (!summary.isEmpty()) {
            if (summary.length() > 800) summary = summary.left(800) + QStringLiteral("…");
            summary.replace(QLatin1Char('\n'), QLatin1Char(' '));
            item += QStringLiteral("   ") + summary + QLatin1Char('\n');
        }
        item += QLatin1Char('\n');

        if (includeContent) {
            QString content = result.value(QStringLiteral("content")).toString();
            if (!content.isEmpty()) {
                if (content.length() > perItemContentLimit) content = content.left(perItemContentLimit) + QStringLiteral("…");
                item += content + QStringLiteral("\n\n");
            }
        }

        if (formatted.length() + item.length() > maxChars) {
            formatted += QStringLiteral("（结果已按长度截断）\n");
            break;
        }
        formatted += item;
    }

    return count == 0 ? QString() : formatted;
}

SearchOutcome parseSearchResponse(const SearchConfig& config, const QByteArray& body, const QString& query) {
    SearchOutcome outcome;

    QJsonParseError     parseError{};
    const QJsonDocument document = QJsonDocument::fromJson(body, &parseError);
    if (parseError.error != QJsonParseError::NoError || !document.isObject()) {
        outcome.error   = QStringLiteral("响应格式错误");
        outcome.summary = outcome.error;
        outcome.result  = QStringLiteral("搜索失败: ") + outcome.error;
        return outcome;
    }

    const QJsonObject object  = document.object();
    const QJsonArray  results = object.value(QStringLiteral("results")).toArray();
    const QString     formatted = formatSearchResults(
        query,
        results,
        config.provider == QLatin1String("tavily") ? true : config.needContent,
        config.maxChars);

    if (formatted.isEmpty()) {
        // An empty result set is a successful search, just with nothing to cite.
        outcome.success = true;
        outcome.summary = QStringLiteral("未找到结果");
        outcome.result  = QStringLiteral("未找到相关结果");
        return outcome;
    }

    outcome.success = true;
    outcome.summary = QStringLiteral("找到 %1 条结果").arg(results.size());
    outcome.result  = formatted;
    return outcome;
}

struct WebSearchTool::Private {
    SearchConfig                       config;
    Transport                          transport;
    Callbacks                          callbacks;
    QHash<QString, Pending>            inFlight;
    int                                retryDelayMs = 1500;
    quint64                            generation   = 0;

    void dispatch(const QString& callId, const SearchHttpRequest& request);
    void complete(const QString& callId, bool success, const QString& summary, const QString& result);
};

void WebSearchTool::Private::complete(
    const QString& callId,
    bool success,
    const QString& summary,
    const QString& result) {
    inFlight.remove(callId);
    if (callbacks.finished) callbacks.finished(callId, success, summary, result);
}

void WebSearchTool::Private::dispatch(const QString& callId, const SearchHttpRequest& request) {
    if (!transport) {
        complete(callId, false, QStringLiteral("搜索不可用"), QStringLiteral("搜索失败: 未配置网络传输"));
        return;
    }
    if (!inFlight.contains(callId)) return;

    const quint64 attemptGeneration = generation;
    transport(request, [this, callId, request, attemptGeneration](
                            int status, const QByteArray& body, const QString& error) {
        // Cancelled or superseded: the callback may arrive after cancelAll().
        if (attemptGeneration != generation || !inFlight.contains(callId)) return;

        const bool retryable = status == 408 || status == 429 || status >= 500;
        const int  attempt   = inFlight.value(callId).attempt;
        if (retryable && attempt < 1) {
            inFlight[callId].attempt = attempt + 1;
            const quint64 scheduled  = generation;
            QTimer::singleShot(retryDelayMs, [this, callId, request, scheduled]() {
                if (scheduled != generation || !inFlight.contains(callId)) return;
                dispatch(callId, request);
            });
            return;
        }

        const QString query = inFlight.value(callId).query;
        if (!error.isEmpty()) {
            complete(
                callId,
                false,
                error,
                QStringLiteral("搜索失败: ") + error);
            return;
        }
        if (status < 200 || status >= 300) {
            const QString detail = QStringLiteral("搜索失败（HTTP %1）").arg(status);
            complete(callId, false, detail, detail);
            return;
        }

        const SearchOutcome outcome = parseSearchResponse(config, body, query);
        complete(callId, outcome.success, outcome.summary, outcome.result);
    });
}

WebSearchTool::WebSearchTool() : d(std::make_unique<Private>()) {}

WebSearchTool::~WebSearchTool() = default;

void WebSearchTool::setConfig(SearchConfig config) { d->config = std::move(config); }

SearchConfig WebSearchTool::config() const { return d->config; }

void WebSearchTool::setTransport(Transport transport) { d->transport = std::move(transport); }

void WebSearchTool::setCallbacks(Callbacks callbacks) { d->callbacks = std::move(callbacks); }

void WebSearchTool::setRetryDelayMs(int delayMs) { d->retryDelayMs = delayMs; }

std::optional<QString> WebSearchTool::start(
    const QString& callId,
    const QString& query,
    const QString& fallbackApiKey) {
    if (callId.isEmpty()) return QStringLiteral("工具调用 id 为空，本次没有执行。");
    if (query.trimmed().isEmpty()) return QStringLiteral("搜索关键词为空，本次没有执行。");
    if (!d->config.enabled || d->config.provider == QLatin1String("off")) {
        return QStringLiteral("搜索工具未启用，本次没有执行。");
    }
    if (!d->config.configured(fallbackApiKey)) {
        return QStringLiteral("搜索服务未配置 API Key，本次没有执行。");
    }
    if (d->inFlight.contains(callId)) return QStringLiteral("重复的工具调用，本次没有执行。");

    auto request = buildSearchRequest(d->config, query, fallbackApiKey);
    if (!request) return QStringLiteral("搜索请求无法构造，本次没有执行。");

    d->inFlight.insert(callId, Pending{query, 0});
    if (d->callbacks.started) d->callbacks.started(callId, query);
    d->dispatch(callId, *request);
    return std::nullopt;
}

void WebSearchTool::cancelAll(const QString& reason) {
    ++d->generation;
    const QStringList ids = d->inFlight.keys();
    d->inFlight.clear();
    for (const auto& callId : ids) {
        if (d->callbacks.finished) d->callbacks.finished(callId, false, reason, reason);
    }
}

bool WebSearchTool::busy() const { return !d->inFlight.isEmpty(); }

int WebSearchTool::inFlight() const { return d->inFlight.size(); }

} // namespace mod::chatbot
