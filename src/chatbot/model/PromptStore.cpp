// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "PromptStore.h"

namespace mod::chatbot {

PromptStore::PromptStore(const QJsonObject& section) {
    const QJsonValue prompts = section.value(QStringLiteral("prompts"));
    if (prompts.isArray()) {
        for (const auto& value : prompts.toArray()) {
            const QJsonObject prompt = value.toObject();
            if (prompt.value(QStringLiteral("id")).toString().isEmpty()) continue;
            if (prompt.value(QStringLiteral("name")).toString().isEmpty()) continue;
            m_prompts.append(prompt);
        }
    }
    m_activeId = section.value(QStringLiteral("activePromptId")).toString();
    normalizeActive();
}

PromptStore PromptStore::createDefault(const QString& content) {
    QJsonObject prompt;
    prompt.insert(QStringLiteral("id"), QStringLiteral("default"));
    prompt.insert(QStringLiteral("name"), QStringLiteral("通用助手"));
    prompt.insert(QStringLiteral("content"), content);

    PromptStore store;
    store.m_prompts.append(prompt);
    store.m_activeId = QStringLiteral("default");
    return store;
}

void PromptStore::normalizeActive() {
    if (!m_activeId.isEmpty() && ids().contains(m_activeId)) return;
    m_activeId = m_prompts.isEmpty()
                   ? QString()
                   : m_prompts.first().toObject().value(QStringLiteral("id")).toString();
}

QStringList PromptStore::ids() const {
    QStringList result;
    for (const auto& value : m_prompts) result.append(value.toObject().value(QStringLiteral("id")).toString());
    return result;
}

QString PromptStore::activeName() const {
    for (const auto& value : m_prompts) {
        const QJsonObject prompt = value.toObject();
        if (prompt.value(QStringLiteral("id")).toString() == m_activeId) {
            return prompt.value(QStringLiteral("name")).toString();
        }
    }
    return {};
}

QString PromptStore::activeContent() const {
    for (const auto& value : m_prompts) {
        const QJsonObject prompt = value.toObject();
        if (prompt.value(QStringLiteral("id")).toString() == m_activeId) {
            return prompt.value(QStringLiteral("content")).toString();
        }
    }
    return {};
}

QJsonObject PromptStore::activePromptJson() const {
    for (const auto& value : m_prompts) {
        QJsonObject prompt = value.toObject();
        if (prompt.value(QStringLiteral("id")).toString() != m_activeId) continue;
        prompt.insert(QStringLiteral("isActive"), true);
        return prompt;
    }
    return {};
}

QJsonObject PromptStore::toJson() const {
    QJsonObject result;
    result.insert(QStringLiteral("prompts"), m_prompts);
    result.insert(QStringLiteral("activePromptId"), m_activeId);
    return result;
}

bool PromptStore::setActive(const QString& id) {
    if (!ids().contains(id)) return false;
    m_activeId = id;
    return true;
}

bool PromptStore::upsert(const QJsonObject& input, QString* error) {
    const QString id      = input.value(QStringLiteral("id")).toString();
    const QString name    = input.value(QStringLiteral("name")).toString();
    const QString content = input.value(QStringLiteral("content")).toString();
    if (id.isEmpty() || name.isEmpty()) {
        if (error) *error = QStringLiteral("缺少必填字段 (id, name)");
        return false;
    }

    QJsonObject prompt;
    prompt.insert(QStringLiteral("id"), id);
    prompt.insert(QStringLiteral("name"), name);
    prompt.insert(QStringLiteral("content"), content);

    for (int i = 0; i < m_prompts.size(); ++i) {
        if (m_prompts.at(i).toObject().value(QStringLiteral("id")).toString() != id) continue;
        m_prompts.replace(i, prompt);
        return true;
    }
    m_prompts.append(prompt);
    if (m_activeId.isEmpty()) m_activeId = id;
    return true;
}

bool PromptStore::remove(const QString& id) {
    for (int i = 0; i < m_prompts.size(); ++i) {
        if (m_prompts.at(i).toObject().value(QStringLiteral("id")).toString() != id) continue;
        m_prompts.removeAt(i);
        if (m_activeId == id) normalizeActive();
        return true;
    }
    return false;
}

} // namespace mod::chatbot
