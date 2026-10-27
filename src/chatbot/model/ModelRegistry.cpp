// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "ModelRegistry.h"

#include <QJsonDocument>

namespace mod::chatbot {

namespace {

const QStringList& reasoningEfforts() {
    static const QStringList values = {
        QStringLiteral("none"),
        QStringLiteral("minimal"),
        QStringLiteral("low"),
        QStringLiteral("medium"),
        QStringLiteral("high"),
        QStringLiteral("xhigh"),
    };
    return values;
}

const QStringList& nativeSearchProviders() {
    static const QStringList values = {
        QStringLiteral("auto"),
        QStringLiteral("openai"),
        QStringLiteral("xai"),
        QStringLiteral("compatible"),
    };
    return values;
}

QJsonObject normalizedCapabilities(const QJsonValue& value) {
    const QJsonObject input = value.toObject();
    QJsonObject       caps;
    caps.insert(QStringLiteral("text"), input.value(QStringLiteral("text")).toBool(true));
    caps.insert(QStringLiteral("vision"), input.value(QStringLiteral("vision")).toBool(false));
    caps.insert(QStringLiteral("audio"), input.value(QStringLiteral("audio")).toBool(false));
    caps.insert(QStringLiteral("toolCall"), input.value(QStringLiteral("toolCall")).toBool(false));
    caps.insert(QStringLiteral("reasoning"), input.value(QStringLiteral("reasoning")).toBool(false));
    caps.insert(QStringLiteral("imageGeneration"), input.value(QStringLiteral("imageGeneration")).toBool(false));
    return caps;
}

QJsonObject normalizedExtraParams(const QJsonValue& value) {
    if (value.isObject()) return value.toObject();
    if (value.isString()) {
        const QJsonDocument parsed = QJsonDocument::fromJson(value.toString().toUtf8());
        if (parsed.isObject()) return parsed.object();
    }
    return {};
}

ModelCapabilities capabilitiesOf(const QJsonObject& source) {
    const QJsonObject caps = source.value(QStringLiteral("capabilities")).toObject();
    ModelCapabilities result;
    result.text            = caps.value(QStringLiteral("text")).toBool(true);
    result.vision          = caps.value(QStringLiteral("vision")).toBool(false);
    result.audio           = caps.value(QStringLiteral("audio")).toBool(false);
    result.toolCall        = caps.value(QStringLiteral("toolCall")).toBool(false);
    result.reasoning       = caps.value(QStringLiteral("reasoning")).toBool(false);
    result.imageGeneration = caps.value(QStringLiteral("imageGeneration")).toBool(false);
    return result;
}

} // namespace

ModelRegistry::ModelRegistry(const QJsonObject& section) {
    const QJsonValue models = section.value(QStringLiteral("models"));
    if (models.isArray()) {
        for (const auto& value : models.toArray()) {
            bool              ok    = false;
            const QJsonObject model = normalizeModel(value.toObject(), &ok);
            if (ok) m_models.append(model);
        }
    }
    m_activeId = section.value(QStringLiteral("activeModelId")).toString();
    if (!m_activeId.isEmpty() && !hasModel(m_activeId)) m_activeId.clear();
    if (m_activeId.isEmpty() && !m_models.isEmpty()) {
        m_activeId = m_models.first().toObject().value(QStringLiteral("id")).toString();
    }
}

ModelRegistry ModelRegistry::createDefault(
    const QString& endpoint,
    const QString& apiKey,
    const QString& model,
    double         temperature,
    const QString& proxyVisionPrompt) {
    QJsonObject entry;
    entry.insert(QStringLiteral("id"), model);
    entry.insert(QStringLiteral("name"), QStringLiteral("DeepSeek V4.1 Flash"));
    entry.insert(QStringLiteral("provider"), QStringLiteral("DeepSeek"));
    entry.insert(QStringLiteral("endpoint"), endpoint);
    entry.insert(QStringLiteral("apiKey"), apiKey);
    entry.insert(QStringLiteral("modelId"), model);
    entry.insert(QStringLiteral("apiProtocol"), QStringLiteral("chat_completions"));
    entry.insert(QStringLiteral("temperature"), temperature);
    entry.insert(QStringLiteral("reasoningEffort"), QString());
    entry.insert(QStringLiteral("extraParams"), QJsonObject{});
    entry.insert(QStringLiteral("proxyVisionModelId"), QString());
    entry.insert(QStringLiteral("proxyVisionPrompt"), proxyVisionPrompt);

    ModelRegistry registry;
    bool          ok    = false;
    const QJsonObject normalized = normalizeModel(entry, &ok);
    if (ok) registry.m_models.append(normalized);
    registry.m_activeId = ok ? normalized.value(QStringLiteral("id")).toString() : QString();
    return registry;
}

QJsonObject ModelRegistry::normalizeModel(const QJsonObject& input, bool* ok, QString* error) {
    if (ok) *ok = false;

    const QString id       = input.value(QStringLiteral("id")).toString();
    const QString modelId  = input.value(QStringLiteral("modelId")).toString();
    const QString endpoint = input.value(QStringLiteral("endpoint")).toString();
    if (id.isEmpty() || modelId.isEmpty() || endpoint.isEmpty()) {
        if (error) *error = QStringLiteral("缺少必填字段 (id, modelId, endpoint)");
        return {};
    }

    QString protocol = input.value(QStringLiteral("apiProtocol")).toString();
    if (protocol != QLatin1String("responses")) protocol = QStringLiteral("chat_completions");

    QString effort = input.value(QStringLiteral("reasoningEffort")).toString();
    if (!reasoningEfforts().contains(effort)) effort.clear();

    QString searchProvider = input.value(QStringLiteral("nativeWebSearchProvider")).toString();
    if (!nativeSearchProviders().contains(searchProvider)) searchProvider = QStringLiteral("auto");

    QJsonObject model;
    model.insert(QStringLiteral("id"), id);
    model.insert(QStringLiteral("name"), input.value(QStringLiteral("name")).toString());
    model.insert(QStringLiteral("provider"), input.value(QStringLiteral("provider")).toString());
    model.insert(QStringLiteral("endpoint"), endpoint);
    model.insert(QStringLiteral("apiKey"), input.value(QStringLiteral("apiKey")).toString());
    model.insert(QStringLiteral("modelId"), modelId);
    model.insert(QStringLiteral("apiProtocol"), protocol);
    model.insert(
        QStringLiteral("temperature"),
        input.contains(QStringLiteral("temperature")) ? input.value(QStringLiteral("temperature")).toDouble() : 0.7);
    model.insert(
        QStringLiteral("maxContextSize"),
        input.contains(QStringLiteral("maxContextSize")) ? input.value(QStringLiteral("maxContextSize")).toInt() : 0);
    model.insert(QStringLiteral("reasoningEffort"), effort);
    model.insert(
        QStringLiteral("nativeWebSearchEnabled"),
        input.value(QStringLiteral("nativeWebSearchEnabled")).toBool(false));
    model.insert(QStringLiteral("nativeWebSearchProvider"), searchProvider);
    model.insert(QStringLiteral("capabilities"), normalizedCapabilities(input.value(QStringLiteral("capabilities"))));
    model.insert(QStringLiteral("extraParams"), normalizedExtraParams(input.value(QStringLiteral("extraParams"))));
    model.insert(
        QStringLiteral("proxyVisionModelId"),
        input.value(QStringLiteral("proxyVisionModelId")).toString());
    model.insert(
        QStringLiteral("proxyVisionPrompt"),
        input.value(QStringLiteral("proxyVisionPrompt")).toString());

    if (ok) *ok = true;
    return model;
}

QStringList ModelRegistry::ids() const {
    QStringList result;
    for (const auto& value : m_models) result.append(value.toObject().value(QStringLiteral("id")).toString());
    return result;
}

bool ModelRegistry::hasModel(const QString& id) const {
    for (const auto& value : m_models) {
        if (value.toObject().value(QStringLiteral("id")).toString() == id) return true;
    }
    return false;
}

QJsonObject ModelRegistry::modelJson(const QString& id) const {
    for (const auto& value : m_models) {
        const QJsonObject model = value.toObject();
        if (model.value(QStringLiteral("id")).toString() == id) return model;
    }
    return {};
}

ActiveModel ModelRegistry::active() const {
    ActiveModel result;
    const QJsonObject model = modelJson(m_activeId);
    if (model.isEmpty()) return result;

    result.id                        = model.value(QStringLiteral("id")).toString();
    result.name                      = model.value(QStringLiteral("name")).toString();
    result.provider                  = model.value(QStringLiteral("provider")).toString();
    result.endpoint                  = model.value(QStringLiteral("endpoint")).toString();
    result.apiKey                    = model.value(QStringLiteral("apiKey")).toString();
    result.modelId                   = model.value(QStringLiteral("modelId")).toString();
    result.apiProtocol               = model.value(QStringLiteral("apiProtocol")).toString();
    result.temperature               = model.value(QStringLiteral("temperature")).toDouble(0.7);
    result.maxContextSize            = model.value(QStringLiteral("maxContextSize")).toInt();
    result.reasoningEffort           = model.value(QStringLiteral("reasoningEffort")).toString();
    result.nativeWebSearchEnabled    = model.value(QStringLiteral("nativeWebSearchEnabled")).toBool();
    result.nativeWebSearchProvider   = model.value(QStringLiteral("nativeWebSearchProvider")).toString();
    result.extraParams               = model.value(QStringLiteral("extraParams")).toObject();
    result.capabilities              = capabilitiesOf(model);
    result.proxyVisionModelId        = model.value(QStringLiteral("proxyVisionModelId")).toString();
    result.proxyVisionPrompt         = model.value(QStringLiteral("proxyVisionPrompt")).toString();
    return result;
}

QJsonObject ModelRegistry::activeModelJson() const {
    QJsonObject model = modelJson(m_activeId);
    if (model.isEmpty()) return {};
    model.insert(QStringLiteral("isActive"), true);
    return model;
}

QJsonObject ModelRegistry::toJson() const {
    QJsonObject result;
    result.insert(QStringLiteral("models"), m_models);
    result.insert(QStringLiteral("activeModelId"), m_activeId);
    return result;
}

bool ModelRegistry::setActive(const QString& id) {
    if (!hasModel(id)) return false;
    m_activeId = id;
    return true;
}

bool ModelRegistry::upsert(const QJsonObject& input, QString* error) {
    bool              ok    = false;
    const QJsonObject model = normalizeModel(input, &ok, error);
    if (!ok) return false;

    const QString id = model.value(QStringLiteral("id")).toString();
    for (int i = 0; i < m_models.size(); ++i) {
        if (m_models.at(i).toObject().value(QStringLiteral("id")).toString() != id) continue;
        m_models.replace(i, model);
        return true;
    }
    m_models.append(model);
    if (m_activeId.isEmpty()) m_activeId = id;
    return true;
}

bool ModelRegistry::remove(const QString& id) {
    for (int i = 0; i < m_models.size(); ++i) {
        if (m_models.at(i).toObject().value(QStringLiteral("id")).toString() != id) continue;

        m_models.removeAt(i);
        for (int k = 0; k < m_models.size(); ++k) {
            QJsonObject model = m_models.at(k).toObject();
            if (model.value(QStringLiteral("proxyVisionModelId")).toString() != id) continue;
            model.insert(QStringLiteral("proxyVisionModelId"), QString());
            m_models.replace(k, model);
        }
        if (m_activeId == id) {
            m_activeId = m_models.isEmpty()
                           ? QString()
                           : m_models.first().toObject().value(QStringLiteral("id")).toString();
        }
        return true;
    }
    return false;
}

} // namespace mod::chatbot
