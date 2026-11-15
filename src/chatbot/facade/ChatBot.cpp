// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "ChatBot.h"

#include "chatbot/AttachmentManager.h"
#include "chatbot/MarkdownParser.h"
#include "chatbot/context/ContextAssembler.h"
#include "chatbot/engine/ChatEngine.h"
#include "chatbot/model/ModelRegistry.h"
#include "chatbot/model/PromptStore.h"
#include "chatbot/session/SessionManager.h"
#include "chatbot/tools/ReadTool.h"
#include "chatbot/tools/ShellTool.h"
#include "chatbot/tools/ToolRuntime.h"
#include "chatbot/tools/WebSearchTool.h"

#include "common/Event.h"
#include "common/Utils.h"
#include "common/util/System.h"
#include "mod/Config.h"

#include <QQmlContext>
#include <QQuickView>

#include <QDateTime>
#include <QElapsedTimer>
#include <QDir>
#include <QFile>
#include <QImageReader>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMutexLocker>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QPointer>
#include <QRunnable>
#include <QSaveFile>
#include <QSet>
#include <QTextCursor>
#include <QTextDocument>
#include <QTextStream>
#include <QThreadPool>
#include <QTimer>
#include <QUuid>
#include <QUrl>

#include <nlohmann/json.hpp>

#include <algorithm>
#include <functional>

namespace mod::chatbot {

using json = nlohmann::json;

namespace {

QString moduleDir() {
    return mod::util::getModuleFileInfo().absolutePath();
}

json toNlohmann(const QJsonObject& object) {
    return json::parse(QJsonDocument(object).toJson(QJsonDocument::Compact).toStdString(), nullptr, false);
}

QJsonObject toQtObject(const json& value) {
    if (!value.is_object()) return {};
    return QJsonDocument::fromJson(QByteArray::fromStdString(value.dump())).object();
}

// DeepSeek 的峰谷计费窗口，单位 UTC：周一至周五 01:00-04:00 与 06:00-10:00。
bool isPeakHourUtc(const QDateTime& utc) {
    const int dayOfWeek = utc.date().dayOfWeek(); // 1 = 周一
    if (dayOfWeek > 5) return false;
    const int minutes = utc.time().hour() * 60 + utc.time().minute();
    return (minutes >= 1 * 60 && minutes < 4 * 60) || (minutes >= 6 * 60 && minutes < 10 * 60);
}

// 工具卡只显示一行：「运行命令 · <命令首行>」，太长就截断。
QString toolLineLabel(const QString& raw, int maxChars = 60) {
    QString line = raw.section(QLatin1Char('\n'), 0, 0).trimmed();
    if (line.size() > maxChars) line = line.left(maxChars - 1) + QStringLiteral("…");
    return line;
}

QJsonArray toQtArray(const json& value) {
    if (!value.is_array()) return {};
    return QJsonDocument::fromJson(QByteArray::fromStdString(value.dump())).array();
}

class MarkdownTask : public QRunnable {
public:
    explicit MarkdownTask(std::function<void()> function) : m_function(std::move(function)) {}

    void run() override {
        if (m_function) m_function();
    }

private:
    std::function<void()> m_function;
};

} // namespace

struct ChatBot::Private {
    ChatBot* q = nullptr;

    QString modulePath;
    std::unique_ptr<QNetworkAccessManager> network;
    std::unique_ptr<SessionManager>        sessions;

    ModelRegistry models;
    PromptStore   prompts;
    SearchConfig  search;
    ShellConfig   shellConfig;

    ChatEngine    engine;
    ShellTool     shellTool;
    WebSearchTool searchTool;

    QThreadPool  markdownPool;
    QMutex       markdownMutex;
    QSet<QString> markdownRequests;

    QString apiKey;
    QString endpoint = QStringLiteral("https://api.deepseek.com/v1/chat/completions");
    QString model    = QStringLiteral("deepseek-flash");
    QString protocol = QStringLiteral("chat_completions");
    qreal   temperature   = 0.7;
    QString defaultPrompt = QStringLiteral("你是一个有用的助手，使用中文回复用户的问题。");
    bool    streaming     = true;
    QString bubbleMode    = QStringLiteral("full");
    bool    mathEnabled   = false;
    QString mathServerPath;

    QHash<QString, QString> toolCommands; // callId -> 命令/查询的首行摘要

    QString      responseMessageId;
    QString      responseSessionId;
    QVariantList responseToolStates;
    ToolBatch    toolBatch;
    bool         cancelled = false;
    quint64      toolBatchGeneration = 0;

    // 单价后备表：ai.pricing[<modelId>] = {input, output, cacheRead}，单位美元/百万
    // token。优先用模型 JSON 里从 {endpoint}/models 拉到的 price*，拉不到才用这张表。
    QHash<QString, QJsonObject> priceTable;

    // 缓存统计/金额全部跟着会话走（sessions 行的 tokens_* / cost），这里只缓存最近
    // 一次查询结果，免得 QML 绑定在每次求值时都打一次 SQL。
    mutable UsageStats statsCache;
    mutable qint64     statsCacheAt = 0;
    bool               statsDirty   = true;

    json readAi() const;
    void persistAi(const json& ai);
    void loadConfig(bool emitSignals);
    void applyActiveModel(bool emitSignals);
    void persistModels();
    void persistPrompts();

    QVector<MessageData> currentMessages() const;
    QString              currentSessionId() const;
    QVariantList         messagesVariant() const;
    void                 appendAssistant(const ChatResult& result, const QVariantList& toolStates);
    void                 updateToolState(
                    const QString& callId,
                    const QString& state,
                    const QString& text,
                    const QString& result = QString());
    void persistToolStates();

    ContextOptions contextOptions() const;
    QJsonArray     toolDefinitions() const;
    void           startRequest(const QVector<MessageData>& messages);
    void           startContinuation();
    void           dispatchTools(const QString& toolCallsJson);
    void           tryFlushTools();
    void           onFinished(const ChatResult& result);
    void           appendToolMessages();
    void           resetRequestState();

    QJsonObject shellDefinition() const;
    QJsonObject readDefinition() const;
    QJsonObject searchDefinition() const;
};

json ChatBot::Private::readAi() const {
    json ai = mod::Config::getInstance().read("ai");
    if (!ai.is_object()) ai = json::object();
    return ai;
}

void ChatBot::Private::persistAi(const json& ai) { mod::Config::getInstance().write("ai", ai, true); }

void ChatBot::Private::loadConfig(bool emitSignals) {
    const json ai = readAi();

    streaming  = ai.value("streaming", true);
    bubbleMode = QString::fromStdString(ai.value("bubble_render_mode", std::string("full")));
    if (bubbleMode != "full" && bubbleMode != "basic" && bubbleMode != "plain") bubbleMode = "full";

    json modelsSection = json::object();
    if (ai.contains("models")) modelsSection["models"] = ai["models"];
    if (ai.contains("activeModelId")) modelsSection["activeModelId"] = ai["activeModelId"];
    if (modelsSection.contains("models") && modelsSection["models"].is_array() && !modelsSection["models"].empty()) {
        models = ModelRegistry(toQtObject(modelsSection));
    } else {
        models = ModelRegistry::createDefault(
            endpoint,
            apiKey,
            model,
            temperature,
            QStringLiteral("请详细描述这张图片的内容。如果图片中有文字，请完整转录。"));
        persistModels();
    }

    json promptsSection = json::object();
    if (ai.contains("prompts")) promptsSection["prompts"] = ai["prompts"];
    if (ai.contains("activePromptId")) promptsSection["activePromptId"] = ai["activePromptId"];
    if (promptsSection.contains("prompts") && promptsSection["prompts"].is_array() && !promptsSection["prompts"].empty()) {
        prompts = PromptStore(toQtObject(promptsSection));
    } else {
        prompts = PromptStore::createDefault(defaultPrompt);
        persistPrompts();
    }
    if (!prompts.activeContent().isEmpty()) defaultPrompt = prompts.activeContent();

    priceTable.clear();
    if (ai.contains("pricing") && ai["pricing"].is_object()) {
        const QJsonObject table = toQtObject(ai["pricing"]);
        for (auto it = table.begin(); it != table.end(); ++it) {
            if (it.value().isObject()) priceTable.insert(it.key(), it.value().toObject());
        }
    }

    QJsonObject searchSection;
    if (ai.contains("search") && ai["search"].is_object()) searchSection = toQtObject(ai["search"]);
    search = SearchConfig::fromJson(searchSection);

    QJsonObject shellSection;
    if (ai.contains("shell_tool") && ai["shell_tool"].is_object()) shellSection = toQtObject(ai["shell_tool"]);
    shellConfig = ShellConfig::fromJson(shellSection);

    mathEnabled = false;
    mathServerPath.clear();
    if (ai.contains("math_render") && ai["math_render"].is_object()) {
        const QJsonObject math = toQtObject(ai["math_render"]);
        mathEnabled            = math.value(QStringLiteral("enabled")).toBool(false);
        mathServerPath         = math.value(QStringLiteral("server_path")).toString();
    }

    applyActiveModel(emitSignals);
    shellTool.setConfig(shellConfig);
    searchTool.setConfig(search);
}

void ChatBot::Private::applyActiveModel(bool emitSignals) {
    const ActiveModel active = models.active();
    apiKey      = active.apiKey;
    endpoint    = active.endpoint;
    model       = active.modelId;
    protocol    = active.apiProtocol;
    temperature = active.temperature;

    if (!emitSignals) return;
    emit q->apiKeyChanged();
    emit q->apiEndpointChanged();
    emit q->modelChanged();
    emit q->apiProtocolChanged();
    emit q->temperatureChanged();
    emit q->activeModelCapabilitiesChanged();
}

void ChatBot::Private::persistModels() {
    json ai             = readAi();
    ai["models"]        = json::parse(QJsonDocument(models.models()).toJson(QJsonDocument::Compact).toStdString(), nullptr, false);
    ai["activeModelId"] = models.activeModelId().toStdString();
    persistAi(ai);
}

void ChatBot::Private::persistPrompts() {
    json ai              = readAi();
    ai["prompts"]        = json::parse(QJsonDocument(prompts.prompts()).toJson(QJsonDocument::Compact).toStdString(), nullptr, false);
    ai["activePromptId"] = prompts.activePromptId().toStdString();
    persistAi(ai);
}

QVector<MessageData> ChatBot::Private::currentMessages() const {
    return sessions ? sessions->messages(sessions->activeSessionId()) : QVector<MessageData>{};
}

QString ChatBot::Private::currentSessionId() const {
    return sessions ? sessions->activeSessionId() : QString();
}

QVariantList ChatBot::Private::messagesVariant() const {
    QVariantList list;
    for (const auto& message : currentMessages()) {
        QVariantMap item;
        item["messageId"]     = message.messageId;
        item["toolStates"]    = message.toolStates;
        item["role"]          = message.role;
        item["content"]       = message.content;
        item["toolCallsJson"] = message.toolCallsJson;
        item["toolCallId"]    = message.toolCallId;
        item["reasoning"]     = message.reasoning;
        if (message.isMultimodal()) {
            QVariantList parts;
            for (const auto& part : message.parts) {
                QVariantMap map;
                map["type"]      = part.type;
                map["text"]      = part.text;
                map["url"]       = part.url;
                map["format"]    = part.format;
                map["localPath"] = part.localPath;
                map["source"]    = part.localPath.isEmpty() ? part.url : QUrl::fromLocalFile(part.localPath).toString();
                map["name"]      = part.name;
                map["mimeType"]  = part.mimeType;
                map["language"]  = part.language;
                map["size"]      = part.size;
                parts.append(map);
            }
            item["parts"] = parts;
        }
        list.append(item);
    }
    return list;
}

void ChatBot::Private::appendAssistant(const ChatResult& result, const QVariantList& toolStates) {
    if (result.content.isEmpty() && result.reasoning.isEmpty() && result.toolCallsJson.isEmpty()
        && result.imagesBase64.isEmpty() && toolStates.isEmpty()) {
        return;
    }

    MessageData assistant;
    assistant.messageId     = result.messageId;
    if (assistant.messageId.isEmpty()) assistant.messageId = QUuid::createUuid().toString(QUuid::WithoutBraces);
    assistant.role          = QStringLiteral("assistant");
    assistant.content       = result.content;
    assistant.reasoning     = result.reasoning;
    assistant.toolCallsJson = result.toolCallsJson;
    assistant.toolStates    = toolStates;

    QVariantList attachments;
    for (const auto& image : result.imagesBase64) {
        MessagePart part;
        part.type     = QStringLiteral("image_url");
        part.url      = QStringLiteral("data:image/png;base64,") + image;
        part.name     = QStringLiteral("generated.png");
        part.mimeType = QStringLiteral("image/png");
        QString error;
        if (!AttachmentManager::persistImage(modulePath, currentSessionId(), part, &error)) continue;
        part.url.clear();
        assistant.parts.append(part);
        attachments.append(QVariantMap{
            {QStringLiteral("type"), part.type},
            {QStringLiteral("localPath"), part.localPath},
            {QStringLiteral("name"), part.name},
            {QStringLiteral("mimeType"), part.mimeType},
        });
    }

    const auto appended = sessions->appendMessage(currentSessionId(), assistant);
    if (!appended) {
        emit q->errorOccurred(QString::fromStdString(appended.error().message));
        return;
    }
    if (!attachments.isEmpty()) emit q->imageAttachmentsReceived(attachments);
    emit q->messagesChanged();
}

void ChatBot::Private::updateToolState(
    const QString& callId,
    const QString& state,
    const QString& text,
    const QString& result) {
    if (responseSessionId != currentSessionId()) return;

    bool found = false;
    for (auto& value : responseToolStates) {
        QVariantMap map = value.toMap();
        if (map.value("callId").toString() != callId) continue;
        const QString oldState = map.value("state").toString();
        if (oldState == "done" || oldState == "error" || oldState == "cancelled") return;
        map["state"] = state;
        map["text"]  = text;
        if (!result.isEmpty()) map["result"] = result;
        value = map;
        found = true;
        emit q->toolStateChanged(map);
        break;
    }
    if (!found) return;

    persistToolStates();
    emit q->toolStatesChanged();
}

void ChatBot::Private::persistToolStates() {
    for (const auto& message : currentMessages()) {
        if (message.messageId != responseMessageId) continue;
        MessageData updated = message;
        updated.toolStates  = responseToolStates;
        (void)sessions->updateMessage(currentSessionId(), responseMessageId, updated);
        break;
    }
}

ContextOptions ChatBot::Private::contextOptions() const {
    ContextOptions options;
    options.systemPrompt        = defaultPrompt;
    options.maxContextTokens    = models.active().maxContextSize > 0 ? models.active().maxContextSize : 128000;
    options.reserveOutputTokens = 0;
    return options;
}

QJsonObject ChatBot::Private::shellDefinition() const {
    QJsonObject parameters{
        {QStringLiteral("type"), QStringLiteral("object")},
        {QStringLiteral("properties"),
         QJsonObject{{QStringLiteral("command"),
                      QJsonObject{{QStringLiteral("type"), QStringLiteral("string")},
                                  {QStringLiteral("description"), QStringLiteral("要执行的 shell 命令")}}}}},
        {QStringLiteral("required"), QJsonArray{QStringLiteral("command")}},
    };
    return QJsonObject{
        {QStringLiteral("type"), QStringLiteral("function")},
        {QStringLiteral("function"),
         QJsonObject{{QStringLiteral("name"), QStringLiteral("shell_exec")},
                     {QStringLiteral("description"), QStringLiteral("在设备上执行一条 shell 命令并返回输出")},
                     {QStringLiteral("parameters"), parameters}}},
    };
}

QJsonObject ChatBot::Private::searchDefinition() const {
    QJsonObject parameters{
        {QStringLiteral("type"), QStringLiteral("object")},
        {QStringLiteral("properties"),
         QJsonObject{{QStringLiteral("query"),
                      QJsonObject{{QStringLiteral("type"), QStringLiteral("string")},
                                  {QStringLiteral("description"), QStringLiteral("搜索关键词")}}}}},
        {QStringLiteral("required"), QJsonArray{QStringLiteral("query")}},
    };
    return QJsonObject{
        {QStringLiteral("type"), QStringLiteral("function")},
        {QStringLiteral("function"),
         QJsonObject{{QStringLiteral("name"), QStringLiteral("web_search")},
                     {QStringLiteral("description"), QStringLiteral("联网搜索最新信息")},
                     {QStringLiteral("parameters"), parameters}}},
    };
}

QJsonObject ChatBot::Private::readDefinition() const {
    QJsonObject parameters{
        {QStringLiteral("type"), QStringLiteral("object")},
        {QStringLiteral("properties"),
         QJsonObject{
             {QStringLiteral("path"),
              QJsonObject{{QStringLiteral("type"), QStringLiteral("string")},
                          {QStringLiteral("description"), QStringLiteral("要读取的文本文件或图片路径")}}},
             {QStringLiteral("offset"),
              QJsonObject{{QStringLiteral("type"), QStringLiteral("integer")},
                          {QStringLiteral("description"), QStringLiteral("从第几行开始（1-based，默认 1）")}}},
             {QStringLiteral("limit"),
              QJsonObject{{QStringLiteral("type"), QStringLiteral("integer")},
                          {QStringLiteral("description"), QStringLiteral("最多读取多少行（默认上限 2000）")}}},
         }},
        {QStringLiteral("required"), QJsonArray{QStringLiteral("path")}},
    };
    return QJsonObject{
        {QStringLiteral("type"), QStringLiteral("function")},
        {QStringLiteral("function"),
         QJsonObject{
             {QStringLiteral("name"), QStringLiteral("read")},
             {QStringLiteral("description"),
              QStringLiteral("读取设备上的文本文件（返回带行号内容）或图片（自动附加到对话，供视觉模型查看）")},
             {QStringLiteral("parameters"), parameters}}},
    };
}

QJsonArray ChatBot::Private::toolDefinitions() const {
    QJsonArray tools;
    const ModelCapabilities caps = models.active().capabilities;
    if (caps.toolCall && search.available(true, apiKey)) tools.append(searchDefinition());
    if (caps.toolCall && shellConfig.enabled) tools.append(shellDefinition());
    if (caps.toolCall) tools.append(readDefinition());
    return tools;
}

void ChatBot::Private::startRequest(const QVector<MessageData>& messages) {
    if (!sessions) return;
    if (apiKey.isEmpty()) {
        emit q->errorOccurred(QStringLiteral("API 密钥未设置\n请进入「设置」页面配置有效的 API 密钥后重试"));
        return;
    }

    ChatRequest request;
    request.endpoint        = endpoint;
    request.apiKey          = apiKey;
    request.protocol        = protocol;
    request.messages        = messages;
    request.options.model           = model;
    request.options.temperature     = temperature;
    request.options.stream          = streaming;
    request.options.capReasoning    = models.active().capabilities.reasoning;
    request.options.capVision       = models.active().capabilities.vision;
    request.options.reasoningEffort = models.active().reasoningEffort;
    request.options.tools           = toolDefinitions();
    request.options.resolveUrl      = [](const MessagePart& part) { return AttachmentManager::requestUrl(part); };
    request.options.extraParams     = models.active().extraParams;

    if (!engine.send(request)) {
        emit q->errorOccurred(QStringLiteral("已有请求进行中"));
    }
}

void ChatBot::Private::startContinuation() {
    if (cancelled) return;
    const AssembledContext context = ContextAssembler::assembleContinuation(currentMessages(), contextOptions());
    startRequest(context.messages);
}

void ChatBot::Private::resetRequestState() {
    responseToolStates.clear();
    toolBatch.clear();
    cancelled = false;
}

void ChatBot::Private::dispatchTools(const QString& toolCallsJson) {
    const QVector<ToolCallSpec> calls = parseToolCalls(toolCallsJson);
    if (calls.isEmpty()) return;

    toolBatch.begin(calls);
    const quint64 batchGeneration = ++toolBatchGeneration;
    QTimer::singleShot(45000, q, [this, batchGeneration]() {
        if (batchGeneration != toolBatchGeneration || !toolBatch.active()) return;
        q->warn("工具批处理超时，强制结束");
        toolBatch.cancelRemaining(QStringLiteral("工具执行超时，请重试"));
        appendToolMessages();
        toolBatch.clear();
        emit q->toolBatchFlushed();
        if (!cancelled) startContinuation();
    });
    responseToolStates.clear();

    for (int index = 0; index < calls.size(); ++index) {
        const ToolCallSpec& call = calls[index];
        QVariantMap state;
        state["key"]       = responseMessageId + QStringLiteral(":tool:") + QString::number(index);
        state["batchId"]   = responseMessageId;
        state["sessionId"] = currentSessionId();
        state["callId"]    = call.id;
        state["name"]      = call.name;
        state["arguments"] = call.arguments;
        state["state"]     = QStringLiteral("pending");
        state["text"]      = QStringLiteral("准备调用");
        state["result"]    = QString();
        responseToolStates.append(state);
        emit q->toolStateChanged(state);
    }
    emit q->toolStatesChanged();
    persistToolStates();
    emit q->toolCallReceived(toolCallsJson);

    for (const auto& call : calls) {
        const QJsonObject args = QJsonDocument::fromJson(call.arguments.toUtf8()).object();
        if (call.name == QLatin1String("shell_exec")) {
            const QString command = args.value(QStringLiteral("command")).toString();
            toolBatch.markRunning(call.id);
            toolCommands.insert(call.id, toolLineLabel(command));
            updateToolState(
                call.id,
                QStringLiteral("running"),
                QStringLiteral("运行命令 · ") + toolCommands.value(call.id)
            );
            const auto rejection = shellTool.request(call.id, command);
            if (rejection) {
                updateToolState(call.id, QStringLiteral("error"), *rejection, *rejection);
                toolBatch.fail(call.id, *rejection);
            }
        } else if (call.name == QLatin1String("read")) {
            const QString path   = args.value(QStringLiteral("path")).toString();
            const int     offset = args.value(QStringLiteral("offset")).toInt();
            const int     limit  = args.value(QStringLiteral("limit")).toInt();
            const QString name   = toolLineLabel(QFileInfo(path).fileName().isEmpty() ? path
                                                                                    : QFileInfo(path).fileName());
            toolBatch.markRunning(call.id);
            toolCommands.insert(call.id, name);
            updateToolState(call.id, QStringLiteral("running"), QStringLiteral("读取 · ") + name);

            const ReadResult read = ReadTool::readFile(path, offset, limit);
            if (!read.ok) {
                updateToolState(call.id, QStringLiteral("error"), QStringLiteral("读取失败 · ") + name, read.error);
                toolBatch.fail(call.id, read.error);
            } else if (read.isImage) {
                // 图片只作为该 trace 行的展开内容显示（QML 按路径加载），不再往会话里
                // 插一条 user 消息，避免干扰对话与协议顺序。
                const QSize imageSize = QImageReader(path).size();
                const QString summary =
                    QStringLiteral("已读取图片：%1（%2，%3x%4，%5 字节）")
                        .arg(path, read.mimeType)
                        .arg(imageSize.width())
                        .arg(imageSize.height())
                        .arg(read.size);
                toolCommands.insert(call.id, QStringLiteral("读取图片 · ") + name);
                updateToolState(call.id, QStringLiteral("done"), QStringLiteral("读取图片 · ") + name, summary);
                toolBatch.resolve(call.id, summary);
            } else {
                toolCommands.insert(call.id, QStringLiteral("读取 · ") + name);
                updateToolState(call.id, QStringLiteral("done"), QStringLiteral("读取 · ") + name, read.text);
                toolBatch.resolve(call.id, read.text);
            }
        } else if (call.name == QLatin1String("web_search")) {
            const QString query = args.value(QStringLiteral("query")).toString();
            toolBatch.markRunning(call.id);
            toolCommands.insert(call.id, toolLineLabel(query));
            updateToolState(
                call.id,
                QStringLiteral("running"),
                QStringLiteral("搜索 · ") + toolCommands.value(call.id)
            );
            const auto rejection = searchTool.start(call.id, query, apiKey);
            if (rejection) {
                updateToolState(call.id, QStringLiteral("error"), *rejection, *rejection);
                toolBatch.fail(call.id, *rejection);
            }
        } else {
            const QString reason = QStringLiteral("不支持的工具: ") + call.name;
            updateToolState(call.id, QStringLiteral("error"), reason, reason);
            toolBatch.fail(call.id, reason);
        }
    }

    tryFlushTools();
}

void ChatBot::Private::appendToolMessages() {
    const QVector<MessageData> messages = toolBatch.toToolMessages();
    for (const auto& message : messages) {
        const auto appended = sessions->appendMessage(currentSessionId(), message);
        if (!appended) {
            emit q->errorOccurred(QString::fromStdString(appended.error().message));
            return;
        }
    }
    if (!messages.isEmpty()) emit q->messagesChanged();
}

void ChatBot::Private::tryFlushTools() {
    if (!toolBatch.active() || !toolBatch.complete()) return;

    appendToolMessages();
    toolBatch.clear();
    emit q->toolBatchFlushed();

    if (!cancelled) startContinuation();
}

void ChatBot::Private::onFinished(const ChatResult& result) {
    const bool cancelled = result.cancelled || this->cancelled;

    const QVariantList states = responseToolStates;
    if (!result.content.isEmpty() || !result.reasoning.isEmpty() || !result.toolCallsJson.isEmpty()
        || !result.imagesBase64.isEmpty() || !states.isEmpty()) {
        appendAssistant(result, states);
    }

    // Token usage belongs to the session the request was started in, not to
    // whatever session the UI happens to show now (the user may have switched).
    const QString usageSession = responseSessionId.isEmpty() ? currentSessionId() : responseSessionId;
    if (!usageSession.isEmpty()
        && (result.usage.inputTokens > 0 || result.usage.outputTokens > 0
            || result.usage.reasoningTokens > 0 || result.usage.cacheReadTokens > 0
            || result.usage.cacheWriteTokens > 0)) {
        const ActiveModel model = models.active();
        UsageCounters     counters;
        counters.input      = result.usage.inputTokens;
        counters.output     = result.usage.outputTokens;
        counters.reasoning  = result.usage.reasoningTokens;
        counters.cacheRead  = result.usage.cacheReadTokens;
        counters.cacheWrite = result.usage.cacheWriteTokens;
        // input 已含缓存命中部分（见 parseUsageObject），命中部分按缓存单价算，
        // 没配缓存单价时退回输入单价。
        // DeepSeek 官方价分峰谷：谷时是峰时的一半，峰时是 UTC 周一至周五
        // 01:00-04:00 与 06:00-10:00（不含中国大陆节假日，这里判断不了）。
        const QDateTime nowUtc = QDateTime::currentDateTimeUtc();
        const bool      peak   = isPeakHourUtc(nowUtc);
        double          priceInput  = model.priceInput;
        double          priceOutput = model.priceOutput;
        double          priceCache  = model.priceCacheRead;
        if (priceInput <= 0 && priceOutput <= 0) {
            const auto fallback = priceTable.value(model.modelId);
            priceInput  = fallback.value(peak ? "inputPeak" : "input").toDouble();
            priceOutput = fallback.value(peak ? "outputPeak" : "output").toDouble();
            priceCache  = fallback.value(peak ? "cacheReadPeak" : "cacheRead").toDouble();
        }
        if (priceCache <= 0) priceCache = priceInput;
        const double uncached = std::max<std::int64_t>(0, counters.input - counters.cacheRead);
        counters.cost = static_cast<double>(uncached) * priceInput / 1e6
                        + static_cast<double>(counters.cacheRead) * priceCache / 1e6
                        + static_cast<double>(counters.output) * priceOutput / 1e6;
        (void)sessions->addUsage(usageSession, counters);
        statsDirty = true;
        emit q->apiCacheStatsChanged();
    }

    if (cancelled) {
        // cancelRequest() stops tools, appends their pending results and emits the
        // terminal signals; it still owns the rest of this path.
        return;
    }

    if (result.failed) {
        emit q->errorOccurred(result.error.isEmpty() ? QStringLiteral("请求失败") : result.error);
        emit q->streamEnd();
        return;
    }

    if (!streaming && !result.content.isEmpty()) emit q->messageReceived(result.content, true);

    if (!result.toolCallsJson.isEmpty()) dispatchTools(result.toolCallsJson);
    emit q->streamEnd();
}

// ---------------------------------------------------------------------------
// facade
// ---------------------------------------------------------------------------

ChatBot::ChatBot() : Logger("ChatBot"), d(std::make_shared<Private>()) {
    d->q          = this;
    d->modulePath = moduleDir();
    d->network    = std::make_unique<QNetworkAccessManager>();

    auto opened = SessionManager::open(d->modulePath + QStringLiteral("/penmods.db"));
    if (opened) {
        d->sessions = std::move(*opened);
    } else {
        error("无法打开会话数据库: {}", opened.error().message);
    }

    d->markdownPool.setMaxThreadCount(1);
    d->markdownPool.setExpiryTimeout(10000);

    const std::weak_ptr<Private> weak = d;
    QNetworkAccessManager*       network = d->network.get();
    const HttpTransport transport = [weak, network](
                               const HttpRequest& request,
                               std::function<void(const QByteArray&)> onData,
                               std::function<void(int, const QByteArray&, const QString&)> onDone) -> HttpCancel {
        if (weak.expired()) return {};
        QNetworkRequest http(request.url);
        http.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
        http.setRawHeader("Authorization", request.authorization);
        http.setRawHeader("User-Agent", "PenMods ChatBot/1.0");
        QNetworkReply* reply = network->post(http, request.body);

        QObject::connect(reply, &QNetworkReply::readyRead, reply, [weak, reply, onData]() {
            if (weak.expired()) return;
            const QByteArray chunk = reply->readAll();
            if (!chunk.isEmpty()) onData(chunk);
        });
        QObject::connect(reply, &QNetworkReply::finished, reply, [weak, reply, onDone]() {
            if (weak.expired()) {
                reply->deleteLater();
                return;
            }
            const int        status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
            const QByteArray body   = reply->readAll();
            const QString    errorText =
                reply->error() == QNetworkReply::NoError ? QString() : reply->errorString();
            reply->deleteLater();
            onDone(status, body, errorText);
        });

        QPointer<QNetworkReply> guarded(reply);
        return [guarded]() {
            if (guarded) guarded->abort();
        };
    };
    d->engine.setTransport(transport);

    d->searchTool.setTransport([weak, network](
                                   const SearchHttpRequest& request,
                                   std::function<void(int, const QByteArray&, const QString&)> done) {
        if (weak.expired()) return;
        QNetworkRequest http(request.url);
        http.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
        http.setRawHeader("Authorization", request.authorization);
        http.setRawHeader("User-Agent", "PenMods ChatBot/1.0");
        QNetworkReply* reply = network->post(http, request.body);
        QObject::connect(reply, &QNetworkReply::finished, reply, [weak, reply, done]() {
            if (weak.expired()) {
                reply->deleteLater();
                return;
            }
            const int        status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
            const QByteArray body   = reply->readAll();
            const QString    errorText =
                reply->error() == QNetworkReply::NoError ? QString() : reply->errorString();
            reply->deleteLater();
            done(status, body, errorText);
        });
    });

    d->engine.setCallbacks(ChatCallbacks{
        [this](const QString& messageId) {
            d->responseMessageId = messageId;
            d->responseSessionId = d->currentSessionId();
            d->responseToolStates.clear();
            d->cancelled = false;
            emit streamStart();
        },
        [this](const QString& text) { emit streamChunk(text); },
        [this](const QString& text) { emit reasoningChunk(text); },
        // 统计只在 onFinished() 落库后刷新（见 recordUsage），流式增量不重复记账。
        [](const UsageDelta&) {},
        {}, // toolCalls: emitted by dispatchTools() after the assistant message exists
        [this](const QString& toolName, const QString& status) {
            const bool done = status != QLatin1String("running");
            emit toolCallProgress((done ? QStringLiteral("已完成：") : QStringLiteral("正在执行：")) + toolName, done);
        },
        [this](const ChatResult& result) { d->onFinished(result); },
    });

    d->shellTool.setCallbacks(ShellTool::Callbacks{
        [this](const QString& callId, const QString& command) { emit shellCommandPending(callId, command); },
        [this](const QString& callId, const QString& command) {
            d->toolCommands.insert(callId, toolLineLabel(command));
            d->updateToolState(
                callId,
                QStringLiteral("running"),
                QStringLiteral("运行命令 · ") + d->toolCommands.value(callId)
            );
            emit shellCommandStarted(callId, command);
        },
        [this](const QString& callId, bool success, const QString& summary, const QString& result) {
            const QString label = d->toolCommands.value(callId);
            d->updateToolState(
                callId,
                success ? QStringLiteral("done") : QStringLiteral("error"),
                label.isEmpty() ? summary : (QStringLiteral("运行命令 · ") + label),
                result);
            if (success) {
                d->toolBatch.resolve(callId, result);
            } else {
                // 退出码非 0 时也要把完整结果（stdout/stderr + 退出码）交给模型：
                // 只回一句 "退出码: 1" 会把命令真正的报错吞掉，模型无从跟进。
                d->toolBatch.fail(callId, result.isEmpty() ? summary : result);
            }
            emit shellCommandFinished(callId, success, summary, result);
            d->tryFlushTools();
        },
    });

    d->searchTool.setCallbacks(WebSearchTool::Callbacks{
        [this](const QString& callId, const QString& query) {
            d->updateToolState(callId, QStringLiteral("running"), QStringLiteral("正在搜索"));
            emit webSearchStarted(callId, query);
            emit tavilySearchStarted(callId, query);
        },
        [this](const QString& callId, bool success, const QString& summary, const QString& result) {
            const QString label = d->toolCommands.value(callId);
            d->updateToolState(
                callId,
                success ? QStringLiteral("done") : QStringLiteral("error"),
                label.isEmpty() ? summary : (QStringLiteral("运行命令 · ") + label),
                result);
            if (success) {
                d->toolBatch.resolve(callId, result);
            } else {
                // 退出码非 0 时也要把完整结果（stdout/stderr + 退出码）交给模型：
                // 只回一句 "退出码: 1" 会把命令真正的报错吞掉，模型无从跟进。
                d->toolBatch.fail(callId, result.isEmpty() ? summary : result);
            }
            emit webSearchFinished(callId, success, summary, result);
            emit tavilySearchFinished(callId, success, summary, result);
            d->tryFlushTools();
        },
    });

    d->loadConfig(false);

    connect(&Event::getInstance(), &Event::beforeUiInitialization, [this](QQuickView&, QQmlContext* context) {
        context->setContextProperty("chatbot", this);
    });

    info("ChatBot 初始化完成, db={}", (d->modulePath + "/penmods.db").toStdString());
}

ChatBot::~ChatBot() = default;

QString ChatBot::getApiKey() const { return d->apiKey; }
QString ChatBot::getApiEndpoint() const { return d->endpoint; }
QString ChatBot::getModel() const { return d->model; }
QString ChatBot::getApiProtocol() const { return d->protocol; }
qreal   ChatBot::getTemperature() const { return d->temperature; }
QString ChatBot::getDefaultPrompt() const { return d->defaultPrompt; }
bool    ChatBot::getIsStreaming() const { return d->streaming; }
QString ChatBot::responseMessageId() const { return d->responseMessageId; }
QString ChatBot::getCurrentSessionId() { return d->currentSessionId(); }
bool    ChatBot::isAvailable() { return !d->apiKey.isEmpty(); }

QVariantList ChatBot::getMessages() const {
    // 性能测量：这个属性每次被 QML 读取都会重建整份列表，大会话下是最重的一步。
    QElapsedTimer timer;
    timer.start();
    QVariantList list = d->messagesVariant();
    const qint64 elapsed = timer.elapsed();
    if (elapsed >= 5 || list.size() >= 50) {
        spdlog::info("getMessages: {} 条消息, {} ms", list.size(), elapsed);
    }
    return list;
}

QVariantList ChatBot::getToolStates() const {
    QVariantList states;
    for (const auto& message : d->currentMessages()) states += message.toolStates;
    if (d->responseSessionId == d->currentSessionId() && d->engine.busy()) {
        for (const auto& value : d->responseToolStates) {
            bool found = false;
            for (const auto& stored : states) {
                found |= stored.toMap().value("key") == value.toMap().value("key");
            }
            if (!found) states.append(value);
        }
    }
    return states;
}

QVariantMap ChatBot::getApiCacheStats() const {
    const qint64 now = QDateTime::currentMSecsSinceEpoch();
    if (d->statsDirty || !d->sessions || now - d->statsCacheAt > 500) {
        d->statsCacheAt = now;
        d->statsCache   = {};
        if (d->sessions) {
            const QString sessionId = d->currentSessionId();
            if (!sessionId.isEmpty()) {
                auto stored = d->sessions->sessionUsage(sessionId);
                if (stored) {
                    d->statsCache = *stored;
                    d->statsDirty = false;
                }
            }
        }
    }

    const auto& stats = d->statsCache;
    return {
        {"inputTokens", QVariant::fromValue<qulonglong>(static_cast<qulonglong>(stats.input))},
        {"outputTokens", QVariant::fromValue<qulonglong>(static_cast<qulonglong>(stats.output))},
        {"cachedTokens", QVariant::fromValue<qulonglong>(static_cast<qulonglong>(stats.cacheRead))},
        {"cacheWriteTokens", QVariant::fromValue<qulonglong>(static_cast<qulonglong>(stats.cacheWrite))},
        {"hitRate", stats.hitRate()},
        {"cost", stats.cost},
    };
}

bool ChatBot::getCapText() const { return d->models.active().capabilities.text; }
bool ChatBot::getCapVision() const { return d->models.active().capabilities.vision; }
bool ChatBot::getCapAudio() const { return d->models.active().capabilities.audio; }
bool ChatBot::getCapToolCall() const { return d->models.active().capabilities.toolCall; }
bool ChatBot::getCapReasoning() const { return d->models.active().capabilities.reasoning; }
bool ChatBot::getCapImageGeneration() const { return d->models.active().capabilities.imageGeneration; }

QString ChatBot::getProxyVisionModelId() const { return d->models.active().proxyVisionModelId; }
QString ChatBot::getProxyVisionPrompt() const { return d->models.active().proxyVisionPrompt; }

QString ChatBot::getSearchProvider() const { return d->search.provider; }
bool    ChatBot::getSearchEnabled() const { return d->search.enabled; }
bool    ChatBot::getSearchConfigured() const { return d->search.configured(d->apiKey); }
int     ChatBot::getSearchCount() const { return d->search.count; }
bool ChatBot::getTavilyEnabled() const {
    return d->search.provider == QLatin1String("tavily") && d->search.enabled;
}
bool    ChatBot::getTavilyConfigured() const { return !d->search.tavilyKey.isEmpty(); }
bool    ChatBot::getShellToolEnabled() const { return d->shellConfig.enabled; }
bool    ChatBot::getMathRenderEnabled() const { return d->mathEnabled; }
QString ChatBot::getMathServerPath() const { return d->mathServerPath; }
QString ChatBot::getBubbleRenderMode() const { return d->bubbleMode; }

void ChatBot::setApiKey(const QString& key) {
    if (d->apiKey == key) return;
    d->apiKey = key;
    emit apiKeyChanged();
}
void ChatBot::setApiEndpoint(const QString& endpoint) {
    if (d->endpoint == endpoint) return;
    d->endpoint = endpoint;
    emit apiEndpointChanged();
}
void ChatBot::setModel(const QString& model) {
    if (d->model == model) return;
    d->model = model;
    emit modelChanged();
}
void ChatBot::setTemperature(qreal temp) {
    if (qFuzzyCompare(d->temperature, temp)) return;
    d->temperature = temp;
    emit temperatureChanged();
}
void ChatBot::setDefaultPrompt(const QString& prompt) {
    if (d->defaultPrompt == prompt) return;
    d->defaultPrompt = prompt;
    emit defaultPromptChanged();
}
void ChatBot::setIsStreaming(bool streaming) {
    if (d->streaming == streaming) return;
    d->streaming = streaming;
    json ai = d->readAi();
    ai["streaming"] = streaming;
    d->persistAi(ai);
    emit isStreamingChanged();
}

void ChatBot::setProxyVisionModelId(const QString& value) {
    QJsonObject input = d->models.activeModelJson();
    if (input.isEmpty()) return;
    input.insert(QStringLiteral("proxyVisionModelId"), value);
    if (!d->models.upsert(input)) return;
    d->persistModels();
    emit proxyVisionSettingsChanged();
}

void ChatBot::setProxyVisionPrompt(const QString& value) {
    QJsonObject input = d->models.activeModelJson();
    if (input.isEmpty()) return;
    input.insert(QStringLiteral("proxyVisionPrompt"), value);
    if (!d->models.upsert(input)) return;
    d->persistModels();
    emit proxyVisionSettingsChanged();
}

void ChatBot::setSearchProvider(const QString& provider) {
    const QString normalized = (provider == QLatin1String("tavily") || provider == QLatin1String("deepseek"))
                                   ? provider
                                   : QStringLiteral("off");
    if (d->search.provider == normalized) return;
    d->search.provider = normalized;
    json ai      = d->readAi();
    ai["search"] = toNlohmann(d->search.toJson());
    d->persistAi(ai);
    d->searchTool.setConfig(d->search);
    emit searchConfigChanged();
    emit tavilyConfigChanged();
}

void ChatBot::setSearchEnabled(bool value) {
    if (d->search.enabled == value) return;
    d->search.enabled = value;
    json ai      = d->readAi();
    ai["search"] = toNlohmann(d->search.toJson());
    d->persistAi(ai);
    emit searchConfigChanged();
    emit tavilyConfigChanged();
}

void ChatBot::setSearchCount(int count) {
    count = qBound(1, count, 50);
    if (d->search.count == count) return;
    d->search.count = count;
    json ai      = d->readAi();
    ai["search"] = toNlohmann(d->search.toJson());
    d->persistAi(ai);
    emit searchConfigChanged();
    emit tavilyConfigChanged();
}

void ChatBot::setTavilyEnabled(bool value) {
    d->search.enabled = value;
    if (value && d->search.provider == QLatin1String("off")) d->search.provider = QStringLiteral("tavily");
    json ai      = d->readAi();
    ai["search"] = toNlohmann(d->search.toJson());
    d->persistAi(ai);
    emit searchConfigChanged();
    emit tavilyConfigChanged();
}

void ChatBot::setShellToolEnabled(bool value) {
    if (d->shellConfig.enabled == value) return;
    d->shellConfig.enabled = value;
    d->shellTool.setConfig(d->shellConfig);
    json ai          = d->readAi();
    ai["shell_tool"] = toNlohmann(d->shellConfig.toJson());
    d->persistAi(ai);
    emit shellToolConfigChanged();
}

void ChatBot::setMathRenderEnabled(bool value) {
    if (d->mathEnabled == value) return;
    d->mathEnabled = value;
    QJsonObject section{{QStringLiteral("enabled"), d->mathEnabled},
                        {QStringLiteral("server_path"), d->mathServerPath}};
    json ai           = d->readAi();
    ai["math_render"] = toNlohmann(section);
    d->persistAi(ai);
    emit mathRenderConfigChanged();
}

void ChatBot::setMathServerPath(const QString& path) {
    if (d->mathServerPath == path) return;
    d->mathServerPath = path;
    QJsonObject section{{QStringLiteral("enabled"), d->mathEnabled},
                        {QStringLiteral("server_path"), d->mathServerPath}};
    json ai           = d->readAi();
    ai["math_render"] = toNlohmann(section);
    d->persistAi(ai);
    emit mathRenderConfigChanged();
}

void ChatBot::setBubbleRenderMode(const QString& mode) {
    const QString normalized =
        (mode == "full" || mode == "basic" || mode == "plain") ? mode : QStringLiteral("full");
    if (d->bubbleMode == normalized) return;
    d->bubbleMode = normalized;
    json ai = d->readAi();
    ai["bubble_render_mode"] = normalized.toStdString();
    d->persistAi(ai);
    emit bubbleRenderModeChanged();
}

void ChatBot::cancelRequest() {
    if (!d->engine.busy() && !d->toolBatch.active() && !d->shellTool.busy() && !d->searchTool.busy()) return;
    d->cancelled = true;
    d->engine.cancel();
    d->shellTool.cancelAll(QStringLiteral("用户取消了请求"));
    d->searchTool.cancelAll(QStringLiteral("用户取消了请求"));
    if (d->toolBatch.active()) {
        d->toolBatch.cancelRemaining(pendingToolResultText());
        d->appendToolMessages();
        d->toolBatch.clear();
        emit toolBatchFlushed();
    }
    d->cancelled = false;
    emit requestCancelled();
    emit streamEnd();
}

void ChatBot::reportPerf(const QString& name, int ms, int rows) {
    spdlog::info("[perf] {} {}ms rows={}", name.toStdString(), ms, rows);
}

void ChatBot::refreshModelPrices() {
    const ActiveModel model = d->models.active();
    if (!d->network || model.endpoint.isEmpty()) return;

    // endpoint 通常是 .../chat/completions 或 .../responses，模型列表在同一 base 下。
    QString base = model.endpoint;
    for (const QString& suffix : {QStringLiteral("/chat/completions"), QStringLiteral("/responses")}) {
        if (base.endsWith(suffix)) {
            base.chop(suffix.size());
            break;
        }
    }
    while (base.endsWith(QLatin1Char('/'))) base.chop(1);

    QNetworkRequest request{QUrl(base + QStringLiteral("/models"))};
    request.setRawHeader("Accept", "application/json");
    if (!model.apiKey.isEmpty())
        request.setRawHeader("Authorization", "Bearer " + model.apiKey.toUtf8());

    QNetworkReply* reply = d->network->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply, model]() {
        const QByteArray body = reply->readAll();
        reply->deleteLater();
        // 拉不到不算错误：多数官方端点（如 DeepSeek）不返回 pricing，金额走
        // config 里的 ai.pricing 表。
        if (reply->error() != QNetworkReply::NoError) return;

        QJsonParseError parseError{};
        const QJsonDocument doc = QJsonDocument::fromJson(body, &parseError);
        if (parseError.error != QJsonParseError::NoError || !doc.isObject()) return;
        const QJsonArray data = doc.object().value(QStringLiteral("data")).toArray();

        // OpenRouter 风格：pricing.prompt / pricing.completion，单位是「美元 / token」，
        // 存成「美元 / 百万 token」以便展示。只认 id 与当前模型 modelId 一致的那条。
        for (const QJsonValue& item : data) {
            const QJsonObject entry = item.toObject();
            if (entry.value(QStringLiteral("id")).toString() != model.modelId) continue;
            const QJsonObject pricing = entry.value(QStringLiteral("pricing")).toObject();
            if (pricing.isEmpty()) continue;
            // 有的服务端把价格写成字符串 "0.000003"，有的写成数字，两种都接受。
            const auto priceOf = [](const QJsonValue& value) {
                return value.isString() ? value.toString().toDouble() : value.toDouble();
            };
            const double prompt     = priceOf(pricing.value(QStringLiteral("prompt")));
            const double completion = priceOf(pricing.value(QStringLiteral("completion")));
            if (prompt <= 0 && completion <= 0) continue;

            QJsonObject updated = d->models.activeModelJson();
            updated.insert(QStringLiteral("priceInput"), prompt * 1e6);
            updated.insert(QStringLiteral("priceOutput"), completion * 1e6);
            // 缓存命中价按输入价计，OpenRouter 没有单独的缓存读字段。
            updated.insert(QStringLiteral("priceCacheRead"), prompt * 1e6);
            (void)d->models.upsert(updated);
            d->persistModels();
            d->applyActiveModel(true);
            d->statsDirty = true;
            emit apiCacheStatsChanged();
            emit apiCacheStatsRefreshed();
            return;
        }
        emit apiCacheStatsRefreshed();
    });
}

void ChatBot::submitToolResult(const QString& toolCallId, const QString& toolName, const QString& result) {
    Q_UNUSED(toolName)
    if (!d->toolBatch.has(toolCallId)) return;
    d->toolBatch.resolve(toolCallId, result);
    d->updateToolState(toolCallId, QStringLiteral("done"), QStringLiteral("完成"), result);
    d->tryFlushTools();
}

QString ChatBot::getShellToolConfig() {
    return QString::fromUtf8(QJsonDocument(d->shellConfig.toJson()).toJson(QJsonDocument::Indented));
}

void ChatBot::setShellToolConfig(const QString& configJson) {
    const QJsonDocument document = QJsonDocument::fromJson(configJson.toUtf8());
    if (!document.isObject()) return;
    d->shellConfig = ShellConfig::fromJson(document.object());
    d->shellTool.setConfig(d->shellConfig);
    json ai          = d->readAi();
    ai["shell_tool"] = toNlohmann(d->shellConfig.toJson());
    d->persistAi(ai);
    emit shellToolConfigChanged();
}

void ChatBot::approveShellCommand(const QString& toolCallId) { d->shellTool.approve(toolCallId); }
void ChatBot::denyShellCommand(const QString& toolCallId) { d->shellTool.deny(toolCallId); }

QString ChatBot::getSessions() {
    QJsonArray array;
    if (d->sessions) {
        for (auto it = d->sessions->sessions().constBegin(); it != d->sessions->sessions().constEnd(); ++it) {
            array.append(QJsonObject{
                {QStringLiteral("id"), it->id},
                {QStringLiteral("title"), it->title},
                {QStringLiteral("createdAt"), it->createdAt},
                {QStringLiteral("updatedAt"), it->updatedAt},
                {QStringLiteral("messageCount"), it->messageCount},
            });
        }
    }
    const QJsonObject root{
        {QStringLiteral("activeSessionId"), d->currentSessionId()},
        {QStringLiteral("sessions"), array},
    };
    return QString::fromUtf8(QJsonDocument(root).toJson(QJsonDocument::Indented));
}

bool ChatBot::switchSession(const QString& sessionId) {
    if (!d->sessions || !d->sessions->hasSession(sessionId)) return false;
    if (d->currentSessionId() == sessionId) return true;
    cancelRequest();
    const auto switched = d->sessions->switchSession(sessionId);
    if (!switched) return false;
    d->responseToolStates.clear();
    emit messagesChanged();
    // 统计跟随会话：切过去之后立刻刷新命中率/金额，别还挂着上一会话的数字。
    d->statsDirty = true;
    emit apiCacheStatsChanged();
    emit sessionSwitched(sessionId);
    return true;
}

QString ChatBot::createSession(const QString& title) {
    if (!d->sessions) return {};
    cancelRequest();
    const auto created = d->sessions->createSession(title);
    if (!created) {
        emit errorOccurred(QString::fromStdString(created.error().message));
        return {};
    }
    d->responseToolStates.clear();
    emit messagesChanged();
    emit sessionsChanged();
    emit sessionSwitched(*created);
    return *created;
}

bool ChatBot::deleteSession(const QString& sessionId) {
    if (!d->sessions) return false;
    if (sessionId == d->currentSessionId()) cancelRequest();
    const bool wasActive = sessionId == d->currentSessionId();
    const auto removed   = d->sessions->deleteSession(sessionId);
    if (!removed) return false;

    AttachmentManager::removeSession(d->modulePath, sessionId);
    if (wasActive) {
        emit messagesChanged();
        emit sessionSwitched(d->currentSessionId());
    }
    emit sessionsChanged();
    return true;
}

bool ChatBot::renameSession(const QString& sessionId, const QString& newTitle) {
    if (!d->sessions) return false;
    const auto renamed = d->sessions->renameSession(sessionId, newTitle);
    if (!renamed) return false;
    emit sessionsChanged();
    return true;
}

QVariantList ChatBot::getSessionMessages(const QString& sessionId) {
    QVariantList list;
    if (!d->sessions) return list;
    for (const auto& message : d->sessions->messages(sessionId)) {
        list.append(QVariantMap{{QStringLiteral("role"), message.role}, {QStringLiteral("content"), message.content}});
    }
    return list;
}

namespace {

QVector<MessagePart> parseMediaParts(const QString& mediaParts, int* rejected = nullptr) {
    QVector<MessagePart> parts;
    const QJsonDocument  document = QJsonDocument::fromJson(mediaParts.toUtf8());
    if (!document.isArray()) return parts;

    for (const auto& value : document.array()) {
        const QJsonObject object = value.toObject();
        MessagePart       part;
        part.type = object.value(QStringLiteral("type")).toString();
        if (part.type == QLatin1String("image_url")) {
            part.url       = object.value(QStringLiteral("url")).toString();
            part.localPath = object.value(QStringLiteral("localPath")).toString();
            part.name      = object.value(QStringLiteral("name")).toString();
            part.mimeType  = object.value(QStringLiteral("mimeType")).toString();
            if (part.url.isEmpty() && part.localPath.isEmpty()) continue;
        } else if (part.type == QLatin1String("input_audio")) {
            part.data   = object.value(QStringLiteral("data")).toString();
            part.format = object.value(QStringLiteral("format")).toString(QStringLiteral("mp3"));
            if (part.data.isEmpty()) continue;
        } else if (part.type == QLatin1String("text")) {
            part.text = object.value(QStringLiteral("text")).toString();
            if (part.text.isEmpty()) continue;
        } else if (part.type == QLatin1String("file")) {
            part.localPath = object.value(QStringLiteral("localPath")).toString();
            part.name      = object.value(QStringLiteral("name")).toString();
            part.mimeType  = object.value(QStringLiteral("mimeType")).toString(QStringLiteral("text/plain"));
            part.language  = object.value(QStringLiteral("language")).toString();
            if (part.localPath.isEmpty()) continue;
            part.size = object.value(QStringLiteral("size")).toVariant().toLongLong();
            if (part.size == 0) part.size = QFileInfo(part.localPath).size();
        } else {
            if (rejected) ++(*rejected);
            continue;
        }
        parts.append(part);
    }
    return parts;
}

QString buildFileContext(const QVector<MessagePart>& parts, QStringList* failed) {
    constexpr qint64 kMaxFileBytes = 1024 * 1024;
    QString          context;
    qint64           total = 0;
    for (const auto& part : parts) {
        if (part.type != QLatin1String("file")) continue;
        const QFileInfo info(part.localPath);
        if (!info.isAbsolute() || !info.isFile() || !info.isReadable() || info.size() > kMaxFileBytes
            || total + info.size() > kMaxFileBytes) {
            if (failed) failed->append(part.name.isEmpty() ? info.fileName() : part.name);
            continue;
        }
        QFile file(info.absoluteFilePath());
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            if (failed) failed->append(part.name.isEmpty() ? info.fileName() : part.name);
            continue;
        }
        const QByteArray data = file.read(kMaxFileBytes + 1);
        if (data.size() > kMaxFileBytes || total + data.size() > kMaxFileBytes) {
            if (failed) failed->append(part.name.isEmpty() ? info.fileName() : part.name);
            continue;
        }
        total += data.size();
        context += QStringLiteral("---\n## 文件: %1\n```%2\n%3\n```\n\n")
                       .arg(info.absoluteFilePath(), part.language, QString::fromUtf8(data));
    }
    return context.isEmpty() ? QString() : QStringLiteral("用户引用了以下文件作为上下文：\n\n") + context;
}

MessagePart makeTextPart(const QString& text) {
    MessagePart part;
    part.type = QStringLiteral("text");
    part.text = text;
    return part;
}

} // namespace

void ChatBot::sendMessage(const QString& message, const QString& fileRefs) {
    QVector<MessagePart> parts;

    if (!fileRefs.isEmpty()) {
        const QJsonDocument document = QJsonDocument::fromJson(fileRefs.toUtf8());
        for (const auto& value : document.array()) {
            const QJsonObject file = value.toObject();
            MessagePart       part;
            part.type      = QStringLiteral("file");
            part.localPath = file.value(QStringLiteral("path")).toString();
            part.name      = file.value(QStringLiteral("name")).toString(QFileInfo(part.localPath).fileName());
            part.mimeType  = QStringLiteral("text/plain");
            part.language  = file.value(QStringLiteral("language")).toString();
            part.size      = QFileInfo(part.localPath).size();
            if (!part.localPath.isEmpty()) parts.append(part);
        }
    }

    QStringList   failed;
    const QString fileContext = buildFileContext(parts, &failed);
    if (!failed.isEmpty()) {
        showToast(QString("%1 个附件未发送，请检查权限或大小").arg(failed.size()).toStdString());
    }
    if (!fileContext.isEmpty()) parts.prepend(makeTextPart(fileContext));
    if (!message.isEmpty() && !parts.isEmpty()) parts.prepend(makeTextPart(message));

    MessageData user;
    user.role    = QStringLiteral("user");
    user.content = message;
    user.parts   = parts;

    if (!d->sessions) return;
    if (d->engine.busy() || d->toolBatch.active()) cancelRequest();
    const auto appended = d->sessions->appendMessage(d->currentSessionId(), user);
    if (!appended) {
        emit errorOccurred(QString::fromStdString(appended.error().message));
        return;
    }
    emit messagesChanged();

    d->resetRequestState();
    QVector<MessageData> history = d->currentMessages();
    if (!history.isEmpty()) history.removeLast();
    const AssembledContext assembled = ContextAssembler::assemble(history, user, d->contextOptions());
    d->startRequest(assembled.messages);
}


void ChatBot::sendMessageWithMedia(const QString& message, const QString& mediaParts) {
    constexpr int kMaxMediaJson = 12 * 1024 * 1024;
    if (mediaParts.size() > kMaxMediaJson) {
        emit errorOccurred(QStringLiteral("图片数据过大，请裁剪或减少拼接范围后重试"));
        return;
    }

    QVector<MessagePart> parts = parseMediaParts(mediaParts);
    QStringList          failed;
    const QString        fileContext = buildFileContext(parts, &failed);
    if (!failed.isEmpty()) showToast(QString("%1 个附件未发送，请检查权限或大小").arg(failed.size()).toStdString());

    bool hasImage = false;
    for (const auto& part : parts) hasImage |= part.type == QLatin1String("image_url");
    if (hasImage && !getCapVision()) {
        if (!getProxyVisionModelId().isEmpty()) {
            emit errorOccurred(QStringLiteral("视觉代理暂未接入新栈，请在设置里关闭代理或改用支持视觉的模型"));
            return;
        }
        showToast("当前模型不支持视觉，已仅发送文字");
        parts.erase(
            std::remove_if(parts.begin(), parts.end(), [](const MessagePart& part) {
                return part.type == QLatin1String("image_url");
            }),
            parts.end());
    }

    for (auto& part : parts) {
        if (part.type != QLatin1String("image_url")) continue;
        if (!part.url.startsWith(QLatin1String("data:"), Qt::CaseInsensitive)) continue;
        QString error;
        if (AttachmentManager::persistImage(d->modulePath, d->currentSessionId(), part, &error)) {
            part.url.clear();
        } else {
            warn("保存图片附件失败: {}", error.toStdString());
            part.url.clear();
            part.localPath.clear();
        }
    }
    parts.erase(
        std::remove_if(parts.begin(), parts.end(), [](const MessagePart& part) {
            return part.type == QLatin1String("image_url") && part.url.isEmpty() && part.localPath.isEmpty();
        }),
        parts.end());

    if (!fileContext.isEmpty()) parts.prepend(makeTextPart(fileContext));
    if (!message.isEmpty() && !parts.isEmpty()) parts.prepend(makeTextPart(message));

    MessageData user;
    user.role    = QStringLiteral("user");
    user.content = message.isEmpty() && hasImage ? QStringLiteral("[图片]") : message;
    user.parts   = parts;
    if (message.trimmed().isEmpty() && user.parts.isEmpty()) {
        emit errorOccurred(QStringLiteral("没有可发送的内容"));
        return;
    }

    if (!d->sessions) return;
    if (d->engine.busy() || d->toolBatch.active()) cancelRequest();
    const auto appended = d->sessions->appendMessage(d->currentSessionId(), user);
    if (!appended) {
        emit errorOccurred(QString::fromStdString(appended.error().message));
        return;
    }
    emit messagesChanged();

    d->resetRequestState();
    QVector<MessageData> history = d->currentMessages();
    if (!history.isEmpty()) history.removeLast();
    const AssembledContext assembled = ContextAssembler::assemble(history, user, d->contextOptions());
    d->startRequest(assembled.messages);
}

void ChatBot::editMessage(int index, const QString& newContent) {
    editMessageWithMedia(index, newContent, QStringLiteral("[]"));
}

void ChatBot::editMessageWithMedia(int index, const QString& newContent, const QString& mediaParts) {
    if (!d->sessions) return;
    const QVector<MessageData> messages = d->currentMessages();
    if (index < 0 || index >= messages.size()) return;
    if (messages[index].role != QLatin1String("user")) return;

    QVector<MessagePart> parts;
    bool                 droppedUserText = false;
    for (const auto& part : messages[index].parts) {
        if (part.type == QLatin1String("image_url")) continue;
        if (part.type == QLatin1String("text") && !droppedUserText && part.text == messages[index].content) {
            droppedUserText = true;
            continue;
        }
        parts.append(part);
    }

    QVector<MessagePart> incoming = parseMediaParts(mediaParts);
    bool                 hasImage = false;
    for (auto& part : incoming) {
        if (part.type != QLatin1String("image_url")) continue;
        if (part.url.startsWith(QLatin1String("data:"), Qt::CaseInsensitive)) {
            QString error;
            if (AttachmentManager::persistImage(d->modulePath, d->currentSessionId(), part, &error)) part.url.clear();
        }
        if (part.url.isEmpty() && part.localPath.isEmpty()) continue;
        parts.append(part);
        hasImage = true;
    }
    if (newContent.trimmed().isEmpty() && !hasImage) {
        emit errorOccurred(QStringLiteral("没有可发送的文字或媒体内容"));
        return;
    }

    MessageData updated = messages[index];
    updated.content     = newContent.isEmpty() && hasImage ? QStringLiteral("[图片]") : newContent;
    updated.parts       = parts;
    if (!newContent.isEmpty()) updated.parts.prepend(makeTextPart(newContent));

    const auto replaced = d->sessions->replaceTail(d->currentSessionId(), index, {updated});
    if (!replaced) {
        emit errorOccurred(QString::fromStdString(replaced.error().message));
        return;
    }
    emit messagesChanged();

    d->resetRequestState();
    const AssembledContext assembled = ContextAssembler::assembleContinuation(d->currentMessages(), d->contextOptions());
    d->startRequest(assembled.messages);
}

void ChatBot::truncateHistory(int index) {
    if (!d->sessions) return;
    const QVector<MessageData> messages = d->currentMessages();
    if (index < 0 || index >= messages.size()) return;
    const auto replaced = d->sessions->replaceTail(d->currentSessionId(), index, {});
    if (replaced) emit messagesChanged();
}

void ChatBot::deleteMessage(int index) {
    if (!d->sessions) return;
    const QVector<MessageData> messages = d->currentMessages();
    if (index < 0 || index >= messages.size()) return;

    QVector<MessageData> tail;
    for (int i = index + 1; i < messages.size(); ++i) tail.append(messages[i]);
    const auto replaced = d->sessions->replaceTail(d->currentSessionId(), index, tail);
    if (replaced) emit messagesChanged();
}

void ChatBot::regenerateMessage(int index) {
    if (!d->sessions) return;
    const QVector<MessageData> messages = d->currentMessages();
    if (index < 0 || index >= messages.size()) return;
    if (messages[index].role != QLatin1String("assistant")) return;

    int userIndex = -1;
    for (int i = index - 1; i >= 0; --i) {
        if (messages[i].role == QLatin1String("user")) {
            userIndex = i;
            break;
        }
    }
    if (userIndex < 0) return;

    const auto replaced = d->sessions->replaceTail(d->currentSessionId(), userIndex + 1, {});
    if (!replaced) return;
    emit messagesChanged();

    d->resetRequestState();
    const AssembledContext assembled = ContextAssembler::assembleContinuation(d->currentMessages(), d->contextOptions());
    d->startRequest(assembled.messages);
}

void ChatBot::clearHistory() {
    cancelRequest();
    if (!d->sessions) return;
    const auto cleared = d->sessions->clearMessages(d->currentSessionId());
    if (!cleared) return;
    d->responseToolStates.clear();
    d->responseMessageId.clear();
    emit messagesChanged();
}

void ChatBot::saveMessages() {
    const QString directory = QStringLiteral("/userdisk/Music/AI/Saved");
    QDir().mkpath(directory);
    const QString path = directory + QStringLiteral("/chat_")
                         + QDateTime::currentDateTime().toString(QStringLiteral("yyyyMMdd_hhmmss"))
                         + QStringLiteral(".md");

    QSaveFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        emit errorOccurred(
            QStringLiteral("保存聊天记录失败\n路径: ") + path + QStringLiteral("\n请检查磁盘空间或目录权限"));
        return;
    }
    QTextStream out(&file);
    out.setCodec("UTF-8");
    out << "# AI 聊天记录\n";
    out << QDateTime::currentDateTime().toString(QStringLiteral("保存时间: yyyy-MM-dd hh:mm:ss")) << "\n\n";
    for (const auto& message : d->currentMessages()) {
        if (message.role == QLatin1String("user")) {
            out << "我：\n" << (message.isMultimodal() ? QStringLiteral("[多模态消息]") : message.content) << "\n\n";
        } else if (message.role == QLatin1String("assistant")) {
            out << "AI：\n" << message.content << "\n\n";
        }
    }
    if (file.commit()) {
        showToast("保存成功");
    } else {
        emit errorOccurred(QStringLiteral("保存聊天记录失败"));
    }
}

QString ChatBot::markdownToHtml(const QString& markdown, const QString& fontFamily) {
    QTextDocument document;
    QFont         font;
    font.setPixelSize(12);
    if (!fontFamily.isEmpty()) font.setFamily(fontFamily);
    document.setDefaultFont(font);
    document.setDefaultStyleSheet(QStringLiteral("body { line-height: 1; }"));
    document.setMarkdown(markdown);
    if (!fontFamily.isEmpty()) {
        QTextCursor cursor(&document);
        cursor.select(QTextCursor::Document);
        QTextCharFormat format;
        format.setFontFamily(fontFamily);
        format.setFontFixedPitch(false);
        cursor.mergeCharFormat(format);
    }
    return document.toHtml();
}

void ChatBot::parseMarkdownAsync(const QString& markdown, const QString& requestId) {
    if (requestId.isEmpty()) return;
    {
        QMutexLocker lock(&d->markdownMutex);
        d->markdownRequests.insert(requestId);
    }

    const std::weak_ptr<Private> weak = d;
    const QString                id   = requestId;
    auto task = std::make_unique<MarkdownTask>([weak, id, markdown]() {
        const QString blocks =
            QString::fromUtf8(QJsonDocument(MarkdownParser::parse(markdown)).toJson(QJsonDocument::Compact));
        auto self = weak.lock();
        if (!self) return;
        {
            QMutexLocker lock(&self->markdownMutex);
            if (!self->markdownRequests.contains(id)) return;
            self->markdownRequests.remove(id);
        }
        QMetaObject::invokeMethod(
            self->q,
            [self, id, blocks]() { emit self->q->markdownParsed(id, blocks); },
            Qt::QueuedConnection);
    });
    d->markdownPool.start(task.release());
}

void ChatBot::cancelMarkdownParse(const QString& requestId) {
    if (requestId.isEmpty()) return;
    QMutexLocker lock(&d->markdownMutex);
    d->markdownRequests.remove(requestId);
}

QString ChatBot::getModels() {
    // QML parses `.models`; keep the old {models, activeModelId} envelope.
    return QString::fromUtf8(QJsonDocument(d->models.toJson()).toJson(QJsonDocument::Indented));
}

bool ChatBot::addModel(const QString& modelJson) {
    const QJsonDocument document = QJsonDocument::fromJson(modelJson.toUtf8());
    if (!document.isObject()) return false;
    QString error;
    if (!d->models.upsert(document.object(), &error)) {
        warn("添加模型失败: {}", error.toStdString());
        return false;
    }
    const bool isActive =
        d->models.activeModelId() == document.object().value(QStringLiteral("id")).toString();
    d->persistModels();
    if (isActive) d->applyActiveModel(true);
    emit modelsChanged();
    return true;
}

bool ChatBot::removeModel(const QString& modelId) {
    if (!d->models.remove(modelId)) return false;
    d->persistModels();
    d->applyActiveModel(true);
    emit modelsChanged();
    return true;
}

bool ChatBot::setActiveModel(const QString& modelId) {
    if (!d->models.setActive(modelId)) return false;
    d->persistModels();
    d->applyActiveModel(true);
    emit modelsChanged();
    return true;
}

QString ChatBot::getActiveModel() {
    return QString::fromUtf8(QJsonDocument(d->models.activeModelJson()).toJson(QJsonDocument::Indented));
}

bool ChatBot::loadModelsFile() {
    d->loadConfig(false);
    emit modelsChanged();
    emit promptsChanged();
    emit searchConfigChanged();
    emit shellToolConfigChanged();
    emit mathRenderConfigChanged();
    d->applyActiveModel(true);
    return true;
}

QString ChatBot::getPrompts() {
    return QString::fromUtf8(QJsonDocument(d->prompts.toJson()).toJson(QJsonDocument::Indented));
}

bool ChatBot::addPrompt(const QString& promptJson) {
    const QJsonDocument document = QJsonDocument::fromJson(promptJson.toUtf8());
    if (!document.isObject()) return false;
    QString error;
    if (!d->prompts.upsert(document.object(), &error)) return false;
    d->persistPrompts();
    if (d->defaultPrompt != d->prompts.activeContent()) {
        d->defaultPrompt = d->prompts.activeContent();
        emit defaultPromptChanged();
    }
    emit promptsChanged();
    return true;
}

bool ChatBot::removePrompt(const QString& promptId) {
    if (!d->prompts.remove(promptId)) return false;
    d->persistPrompts();
    d->defaultPrompt = d->prompts.activeContent();
    emit defaultPromptChanged();
    emit promptsChanged();
    return true;
}

bool ChatBot::setActivePrompt(const QString& promptId) {
    if (!d->prompts.setActive(promptId)) return false;
    d->persistPrompts();
    d->defaultPrompt = d->prompts.activeContent();
    emit defaultPromptChanged();
    emit promptsChanged();
    return true;
}

QString ChatBot::getActivePrompt() {
    return QString::fromUtf8(QJsonDocument(d->prompts.activePromptJson()).toJson(QJsonDocument::Indented));
}

QString ChatBot::getSearchConfig() {
    return QString::fromUtf8(QJsonDocument(d->search.toJson()).toJson(QJsonDocument::Indented));
}

void ChatBot::setSearchConfig(const QString& configJson) {
    const QJsonDocument document = QJsonDocument::fromJson(configJson.toUtf8());
    if (!document.isObject()) return;
    d->search = SearchConfig::fromJson(document.object());
    d->searchTool.setConfig(d->search);
    json ai      = d->readAi();
    ai["search"] = toNlohmann(d->search.toJson());
    d->persistAi(ai);
    emit searchConfigChanged();
    emit tavilyConfigChanged();
}

QString ChatBot::getTavilyConfig() {
    const QJsonObject object{
        {QStringLiteral("apiKey"), d->search.tavilyKey},
        {QStringLiteral("searchDepth"), d->search.tavilyDepth},
        {QStringLiteral("maxResults"), d->search.count},
        {QStringLiteral("enabled"), getTavilyEnabled()},
    };
    return QString::fromUtf8(QJsonDocument(object).toJson(QJsonDocument::Indented));
}

void ChatBot::setTavilyConfig(const QString& configJson) {
    const QJsonDocument document = QJsonDocument::fromJson(configJson.toUtf8());
    if (!document.isObject()) return;
    const QJsonObject object = document.object();
    if (object.contains(QStringLiteral("apiKey"))) d->search.tavilyKey = object.value(QStringLiteral("apiKey")).toString();
    if (object.contains(QStringLiteral("searchDepth"))) {
        d->search.tavilyDepth = object.value(QStringLiteral("searchDepth")).toString();
    }
    if (object.contains(QStringLiteral("maxResults"))) {
        d->search.count = qBound(1, object.value(QStringLiteral("maxResults")).toInt(5), 50);
    }
    if (object.contains(QStringLiteral("enabled"))) {
        d->search.enabled = object.value(QStringLiteral("enabled")).toBool();
        if (d->search.enabled && d->search.provider == QLatin1String("off")) {
            d->search.provider = QStringLiteral("tavily");
        }
    }
    d->searchTool.setConfig(d->search);
    json ai      = d->readAi();
    ai["search"] = toNlohmann(d->search.toJson());
    d->persistAi(ai);
    emit searchConfigChanged();
    emit tavilyConfigChanged();
}

QString ChatBot::getMathRenderConfig() {
    const QJsonObject object{
        {QStringLiteral("enabled"), d->mathEnabled},
        {QStringLiteral("server_path"), d->mathServerPath},
    };
    return QString::fromUtf8(QJsonDocument(object).toJson(QJsonDocument::Indented));
}

void ChatBot::setMathRenderConfig(const QString& configJson) {
    const QJsonDocument document = QJsonDocument::fromJson(configJson.toUtf8());
    if (!document.isObject()) return;
    const QJsonObject object = document.object();
    if (object.contains(QStringLiteral("enabled"))) d->mathEnabled = object.value(QStringLiteral("enabled")).toBool();
    if (object.contains(QStringLiteral("server_path"))) {
        d->mathServerPath = object.value(QStringLiteral("server_path")).toString();
    }
    QJsonObject section{{QStringLiteral("enabled"), d->mathEnabled},
                        {QStringLiteral("server_path"), d->mathServerPath}};
    json ai           = d->readAi();
    ai["math_render"] = toNlohmann(section);
    d->persistAi(ai);
    emit mathRenderConfigChanged();
}

void ChatBot::reloadConfig() {
    mod::Config::getInstance().reload();
    d->loadConfig(false);
    emit apiKeyChanged();
    emit apiEndpointChanged();
    emit modelChanged();
    emit apiProtocolChanged();
    emit temperatureChanged();
    emit defaultPromptChanged();
    emit modelsChanged();
    emit promptsChanged();
    emit searchConfigChanged();
    emit shellToolConfigChanged();
    emit mathRenderConfigChanged();
    showToast("配置已重载");
}

void ChatBot::sanitizeConfig() {
    mod::Config::getInstance().sanitize();
    mod::Config::getInstance().reload();
    d->loadConfig(false);
    emit apiKeyChanged();
    emit modelsChanged();
    emit promptsChanged();
    emit searchConfigChanged();
    emit shellToolConfigChanged();
    emit mathRenderConfigChanged();
    showToast("配置已清洗");
}

} // namespace mod::chatbot
