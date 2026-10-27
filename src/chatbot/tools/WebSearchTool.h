// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include <QByteArray>
#include <QJsonArray>
#include <QJsonObject>
#include <QString>
#include <QUrl>

#include <functional>
#include <memory>
#include <optional>

namespace mod::chatbot {

struct SearchConfig {
    QString provider = QStringLiteral("off"); // off | tavily | deepseek
    bool    enabled  = false;
    int     count    = 5; // 1..50
    bool    needContent = false;
    int     maxChars    = 6000; // 500..20000
    QString tavilyKey;
    QString tavilyDepth = QStringLiteral("advanced");
    QString deepseekKey;
    QString deepseekBaseUrl = QStringLiteral("https://api.deepseek.com");

    [[nodiscard]] static SearchConfig fromJson(const QJsonObject& object);
    [[nodiscard]] QJsonObject        toJson() const; // the getSearchConfig() shape

    [[nodiscard]] bool    configured(const QString& fallbackApiKey) const;
    [[nodiscard]] bool    available(bool capToolCall, const QString& fallbackApiKey) const;
    [[nodiscard]] QString effectiveKey(const QString& fallbackApiKey) const;
};

struct SearchHttpRequest {
    QUrl       url;
    QByteArray body;
    QByteArray authorization; // full "Bearer …" header value
};

// Returns nullopt when the provider is off or has no usable key.
[[nodiscard]] std::optional<SearchHttpRequest>
buildSearchRequest(const SearchConfig& config, const QString& query, const QString& fallbackApiKey);

// Old formatting contract: numbered items, title/url, date|site meta, 800-char
// summary, optional raw content, whole text capped at maxChars.
[[nodiscard]] QString formatSearchResults(
    const QString&    query,
    const QJsonArray& results,
    bool              includeContent,
    int               maxChars);

struct SearchOutcome {
    bool    success = false;
    QString summary;
    QString result;
    QString error;
};

[[nodiscard]] SearchOutcome
parseSearchResponse(const SearchConfig& config, const QByteArray& body, const QString& query);

// Network executor. The transport is injected so the flow (retry, cancel,
// callbacks) is host-testable without touching the network.
class WebSearchTool {
public:
    using Transport =
        std::function<void(const SearchHttpRequest&, std::function<void(int status, const QByteArray& body, const QString& error)>)>;

    struct Callbacks {
        std::function<void(const QString& callId, const QString& query)> started;
        std::function<void(const QString& callId, bool success, const QString& summary, const QString& result)>
            finished;
    };

    WebSearchTool();
    ~WebSearchTool();

    WebSearchTool(const WebSearchTool&) = delete;
    WebSearchTool& operator=(const WebSearchTool&) = delete;

    void setConfig(SearchConfig config);
    [[nodiscard]] SearchConfig config() const;
    void setTransport(Transport transport);
    void setCallbacks(Callbacks callbacks);
    // Tests only: shorten the 408/429/5xx retry delay.
    void setRetryDelayMs(int delayMs);

    // Returns a rejection reason when the provider is unavailable; otherwise
    // starts the request and reports through callbacks.
    [[nodiscard]] std::optional<QString>
    start(const QString& callId, const QString& query, const QString& fallbackApiKey);
    void cancelAll(const QString& reason);

    [[nodiscard]] bool busy() const;
    [[nodiscard]] int  inFlight() const;

private:
    struct Private;
    std::unique_ptr<Private> d;
};

} // namespace mod::chatbot
