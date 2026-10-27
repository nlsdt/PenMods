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

// Prompt list backed by the mod config "ai" section ({prompts, activePromptId}).
// Same shape and validation as the old addPrompt(), minus persistence.
class PromptStore {
public:
    PromptStore() = default;
    explicit PromptStore(const QJsonObject& section);

    static PromptStore createDefault(const QString& content);

    [[nodiscard]] QJsonArray  prompts() const { return m_prompts; }
    [[nodiscard]] QStringList ids() const;
    [[nodiscard]] QString     activePromptId() const { return m_activeId; }
    [[nodiscard]] QString     activeName() const;
    [[nodiscard]] QString     activeContent() const;
    [[nodiscard]] QJsonObject activePromptJson() const; // adds "isActive": true
    [[nodiscard]] QJsonObject toJson() const;           // {prompts, activePromptId}

    bool setActive(const QString& id);
    bool upsert(const QJsonObject& input, QString* error = nullptr);
    bool remove(const QString& id);

private:
    void normalizeActive();

    QJsonArray m_prompts;
    QString    m_activeId;
};

} // namespace mod::chatbot
