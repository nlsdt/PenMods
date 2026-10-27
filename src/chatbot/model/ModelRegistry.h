// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include <QJsonArray>
#include <QJsonObject>
#include <QString>
#include <QStringList>

namespace mod::chatbot {

struct ModelCapabilities {
    bool text            = true;
    bool vision          = false;
    bool audio           = false;
    bool toolCall        = false;
    bool reasoning       = false;
    bool imageGeneration = false;
};

// Typed view of the active model, i.e. exactly what a request needs. The facade
// reads this instead of keeping a dozen parallel Q_PROPERTY members.
struct ActiveModel {
    QString           id;
    QString           name;
    QString           provider;
    QString           endpoint;
    QString           apiKey;
    QString           modelId;
    QString           apiProtocol = QStringLiteral("chat_completions");
    double            temperature = 0.7;
    int               maxContextSize = 0;
    QString           reasoningEffort;
    bool              nativeWebSearchEnabled = false;
    QString           nativeWebSearchProvider = QStringLiteral("auto");
    QJsonObject       extraParams;
    ModelCapabilities capabilities;
    QString           proxyVisionModelId;
    QString           proxyVisionPrompt;
};

// In-memory model list + normalization rules migrated from the old addModel().
// Persistence is the caller's job (mod Config "ai" section), so this class is
// pure Qt JSON and host-testable.
class ModelRegistry {
public:
    ModelRegistry() = default;
    explicit ModelRegistry(const QJsonObject& section);

    // Initial state when the config has no models yet.
    static ModelRegistry createDefault(
        const QString& endpoint,
        const QString& apiKey,
        const QString& model,
        double         temperature,
        const QString& proxyVisionPrompt);

    [[nodiscard]] QJsonArray   models() const { return m_models; }
    [[nodiscard]] QStringList  ids() const;
    [[nodiscard]] QString      activeModelId() const { return m_activeId; }
    [[nodiscard]] bool         hasModel(const QString& id) const;
    [[nodiscard]] QJsonObject  modelJson(const QString& id) const;
    [[nodiscard]] ActiveModel  active() const;
    [[nodiscard]] QJsonObject  activeModelJson() const; // adds "isActive": true
    [[nodiscard]] QJsonObject  toJson() const;          // {models, activeModelId}

    bool setActive(const QString& id);
    // Adds or replaces one model. Returns false and fills `error` when a required
    // field (id, modelId, endpoint) is missing.
    bool upsert(const QJsonObject& input, QString* error = nullptr);
    bool remove(const QString& id);

    // Exposed for tests and for addModel() compatibility.
    static QJsonObject normalizeModel(const QJsonObject& input, bool* ok, QString* error = nullptr);

private:
    QJsonArray  m_models;
    QString     m_activeId;
};

} // namespace mod::chatbot
