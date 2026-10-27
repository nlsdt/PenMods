// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>

#include <memory>

#include "common/service/Logger.h"
#include "common/service/Singleton.h"

namespace mod::chatbot {

// QML-facing facade. Same contract as the frozen Backend ChatBot (46 invokables /
// 31 properties / 43 signals); all work is delegated to the new modules. It is
// registered as `chatbotV2`, and as `chatbot` only when PENMODS_CHATBOT_V2=1, so
// both implementations can run side by side until parity is signed off.
class ChatBot : public QObject, public Singleton<ChatBot>, private Logger {
    Q_OBJECT

    Q_PROPERTY(QString apiKey READ getApiKey WRITE setApiKey NOTIFY apiKeyChanged)
    Q_PROPERTY(QString apiEndpoint READ getApiEndpoint WRITE setApiEndpoint NOTIFY apiEndpointChanged)
    Q_PROPERTY(QString model READ getModel WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(QString apiProtocol READ getApiProtocol NOTIFY apiProtocolChanged)
    Q_PROPERTY(qreal temperature READ getTemperature WRITE setTemperature NOTIFY temperatureChanged)
    Q_PROPERTY(QString defaultPrompt READ getDefaultPrompt WRITE setDefaultPrompt NOTIFY defaultPromptChanged)
    Q_PROPERTY(bool isStreaming READ getIsStreaming WRITE setIsStreaming NOTIFY isStreamingChanged)
    Q_PROPERTY(bool isAvailable READ isAvailable CONSTANT)
    Q_PROPERTY(QVariantList messages READ getMessages NOTIFY messagesChanged)
    Q_PROPERTY(QString responseMessageId READ responseMessageId NOTIFY streamStart)
    Q_PROPERTY(QVariantList toolStates READ getToolStates NOTIFY toolStatesChanged)
    Q_PROPERTY(QString currentSessionId READ getCurrentSessionId NOTIFY sessionSwitched)
    Q_PROPERTY(QVariantMap apiCacheStats READ getApiCacheStats NOTIFY apiCacheStatsChanged)

    Q_PROPERTY(bool capText READ getCapText NOTIFY activeModelCapabilitiesChanged)
    Q_PROPERTY(bool capVision READ getCapVision NOTIFY activeModelCapabilitiesChanged)
    Q_PROPERTY(bool capAudio READ getCapAudio NOTIFY activeModelCapabilitiesChanged)
    Q_PROPERTY(bool capToolCall READ getCapToolCall NOTIFY activeModelCapabilitiesChanged)
    Q_PROPERTY(bool capReasoning READ getCapReasoning NOTIFY activeModelCapabilitiesChanged)
    Q_PROPERTY(bool capImageGeneration READ getCapImageGeneration NOTIFY activeModelCapabilitiesChanged)

    Q_PROPERTY(QString proxyVisionModelId READ getProxyVisionModelId WRITE setProxyVisionModelId NOTIFY
                   proxyVisionSettingsChanged)
    Q_PROPERTY(QString proxyVisionPrompt READ getProxyVisionPrompt WRITE setProxyVisionPrompt NOTIFY
                   proxyVisionSettingsChanged)

    Q_PROPERTY(QString searchProvider READ getSearchProvider WRITE setSearchProvider NOTIFY searchConfigChanged)
    Q_PROPERTY(bool searchEnabled READ getSearchEnabled WRITE setSearchEnabled NOTIFY searchConfigChanged)
    Q_PROPERTY(bool searchConfigured READ getSearchConfigured NOTIFY searchConfigChanged)
    Q_PROPERTY(int searchCount READ getSearchCount WRITE setSearchCount NOTIFY searchConfigChanged)
    Q_PROPERTY(bool tavilyEnabled READ getTavilyEnabled WRITE setTavilyEnabled NOTIFY tavilyConfigChanged)
    Q_PROPERTY(bool tavilyConfigured READ getTavilyConfigured NOTIFY tavilyConfigChanged)

    Q_PROPERTY(bool shellToolEnabled READ getShellToolEnabled WRITE setShellToolEnabled NOTIFY shellToolConfigChanged)

    Q_PROPERTY(bool mathRenderEnabled READ getMathRenderEnabled WRITE setMathRenderEnabled NOTIFY
                   mathRenderConfigChanged)
    Q_PROPERTY(QString mathServerPath READ getMathServerPath WRITE setMathServerPath NOTIFY mathRenderConfigChanged)
    Q_PROPERTY(QString bubbleRenderMode READ getBubbleRenderMode WRITE setBubbleRenderMode NOTIFY
                   bubbleRenderModeChanged)

public:
    // 基础接口
    Q_INVOKABLE void    sendMessage(const QString& message, const QString& fileRefs = QString());
    Q_INVOKABLE void    sendMessageWithMedia(const QString& message, const QString& mediaParts);
    Q_INVOKABLE bool    isAvailable();
    Q_INVOKABLE void    reloadConfig();
    Q_INVOKABLE void    sanitizeConfig();
    Q_INVOKABLE void    clearHistory();
    Q_INVOKABLE void    saveMessages();
    Q_INVOKABLE QString markdownToHtml(const QString& markdown, const QString& fontFamily = QString());
    Q_INVOKABLE void    parseMarkdownAsync(const QString& markdown, const QString& requestId);
    Q_INVOKABLE void    cancelMarkdownParse(const QString& requestId);
    Q_INVOKABLE void    truncateHistory(int index);
    Q_INVOKABLE void    editMessage(int index, const QString& newContent);
    Q_INVOKABLE void    editMessageWithMedia(int index, const QString& newContent, const QString& mediaParts);
    Q_INVOKABLE void    deleteMessage(int index);
    Q_INVOKABLE void    regenerateMessage(int index);
    Q_INVOKABLE void    cancelRequest();
    Q_INVOKABLE void    resetApiCacheStats();

    // Tool Call 接口
    Q_INVOKABLE void submitToolResult(const QString& toolCallId, const QString& toolName, const QString& result);

    // Shell Tool 接口
    Q_INVOKABLE void    approveShellCommand(const QString& toolCallId);
    Q_INVOKABLE void    denyShellCommand(const QString& toolCallId);
    Q_INVOKABLE QString getShellToolConfig();
    Q_INVOKABLE void    setShellToolConfig(const QString& configJson);

    // 多会话管理
    Q_INVOKABLE QString      getSessions();
    Q_INVOKABLE QString      getCurrentSessionId();
    Q_INVOKABLE bool         switchSession(const QString& sessionId);
    Q_INVOKABLE QString      createSession(const QString& title = QString());
    Q_INVOKABLE bool         deleteSession(const QString& sessionId);
    Q_INVOKABLE bool         renameSession(const QString& sessionId, const QString& newTitle);
    Q_INVOKABLE QVariantList getSessionMessages(const QString& sessionId);

    // 多模型管理
    Q_INVOKABLE QString getModels();
    Q_INVOKABLE bool    addModel(const QString& modelJson);
    Q_INVOKABLE bool    removeModel(const QString& modelId);
    Q_INVOKABLE bool    setActiveModel(const QString& modelId);
    Q_INVOKABLE QString getActiveModel();
    Q_INVOKABLE bool    loadModelsFile();

    // 多提示词管理
    Q_INVOKABLE QString getPrompts();
    Q_INVOKABLE bool    addPrompt(const QString& promptJson);
    Q_INVOKABLE bool    removePrompt(const QString& promptId);
    Q_INVOKABLE bool    setActivePrompt(const QString& promptId);
    Q_INVOKABLE QString getActivePrompt();

    // 网络搜索
    Q_INVOKABLE QString getSearchConfig();
    Q_INVOKABLE void    setSearchConfig(const QString& configJson);
    Q_INVOKABLE QString getTavilyConfig();
    Q_INVOKABLE void    setTavilyConfig(const QString& configJson);

    // 数学公式渲染
    Q_INVOKABLE QString getMathRenderConfig();
    Q_INVOKABLE void    setMathRenderConfig(const QString& configJson);

    // Getter/Setter
    QString      getApiKey() const;
    QString      getApiEndpoint() const;
    QString      getModel() const;
    QString      getApiProtocol() const;
    qreal        getTemperature() const;
    QString      getDefaultPrompt() const;
    bool         getIsStreaming() const;
    QVariantList getMessages() const;
    QString      responseMessageId() const;

    QVariantList getToolStates() const;
    QVariantMap  getApiCacheStats() const;

    bool getCapText() const;
    bool getCapVision() const;
    bool getCapAudio() const;
    bool getCapToolCall() const;
    bool getCapReasoning() const;
    bool getCapImageGeneration() const;

    QString getProxyVisionModelId() const;
    void    setProxyVisionModelId(const QString& value);
    QString getProxyVisionPrompt() const;
    void    setProxyVisionPrompt(const QString& value);

    QString getSearchProvider() const;
    bool    getSearchEnabled() const;
    bool    getSearchConfigured() const;
    int     getSearchCount() const;
    void    setSearchProvider(const QString& provider);
    void    setSearchEnabled(bool value);
    void    setSearchCount(int count);

    bool getTavilyEnabled() const;
    bool getTavilyConfigured() const;
    void setTavilyEnabled(bool value);

    bool getShellToolEnabled() const;
    void setShellToolEnabled(bool value);

    bool    getMathRenderEnabled() const;
    QString getMathServerPath() const;
    QString getBubbleRenderMode() const;
    void    setMathRenderEnabled(bool value);
    void    setMathServerPath(const QString& path);
    void    setBubbleRenderMode(const QString& mode);

    void setApiKey(const QString& key);
    void setApiEndpoint(const QString& endpoint);
    void setModel(const QString& model);
    void setTemperature(qreal temp);
    void setDefaultPrompt(const QString& prompt);
    void setIsStreaming(bool streaming);

signals:
    void messageReceived(const QString& content, bool isComplete = true);
    void streamStart();
    void streamChunk(const QString& content);
    void reasoningChunk(const QString& content);
    void markdownParsed(const QString& requestId, const QString& blocksJson);
    void streamEnd();
    void errorOccurred(const QString& error);
    void requestCancelled();
    void toolCallReceived(const QString& toolCallsJson);
    void toolStateChanged(const QVariantMap& state);
    void toolStatesChanged();
    void imageAttachmentsReceived(const QVariantList& attachments);
    void toolCallProgress(const QString& text, bool isComplete);
    void apiKeyChanged();
    void apiEndpointChanged();
    void modelChanged();
    void apiProtocolChanged();
    void temperatureChanged();
    void defaultPromptChanged();
    void isStreamingChanged();
    void messagesChanged();
    void apiCacheStatsChanged();
    void modelsChanged();
    void promptsChanged();
    void sessionsChanged();
    void sessionSwitched(const QString& sessionId);
    void activeModelCapabilitiesChanged();
    void proxyVisionSettingsChanged();
    void proxyVisionStarted();
    void proxyVisionCompleted(const QString& description);
    void searchConfigChanged();
    void webSearchStarted(const QString& toolCallId, const QString& query);
    void webSearchFinished(const QString& toolCallId, bool success, const QString& summary, const QString& resultText);
    void tavilyConfigChanged();
    void tavilySearchStarted(const QString& toolCallId, const QString& query);
    void
    tavilySearchFinished(const QString& toolCallId, bool success, const QString& summary, const QString& resultText);
    void shellToolConfigChanged();
    void shellCommandPending(const QString& toolCallId, const QString& command);
    void shellCommandStarted(const QString& toolCallId, const QString& command);
    void
    shellCommandFinished(const QString& toolCallId, bool success, const QString& summary, const QString& resultText);
    void toolBatchFlushed();
    void mathRenderConfigChanged();
    void bubbleRenderModeChanged();

private:
    friend Singleton<ChatBot>;
    explicit ChatBot();

public:
    ~ChatBot() override;

private:
    struct Private;
    std::shared_ptr<Private> d;
};

} // namespace mod::chatbot
