// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "ProtocolCommon.h"

#include <QJsonArray>

namespace mod::chatbot {

namespace {

qint64 asInt(const QJsonValue& value) {
    return value.toVariant().toLongLong();
}

} // namespace

QString extractReasoningText(const QJsonObject& object) {
    static const char* kStringKeys[] = {
        "reasoning_content",
        "reasoning",
        "reasoning_text",
        "thinking",
        "analysis",
        "thought",
    };
    for (const char* key : kStringKeys) {
        const QJsonValue value = object.value(QLatin1String(key));
        if (!value.isString()) continue;
        const QString text = value.toString();
        if (!text.isEmpty()) return text;
    }

    for (const char* key : {"reasoning", "thinking"}) {
        const QJsonValue value = object.value(QLatin1String(key));
        if (!value.isObject()) continue;
        const QJsonObject nested = value.toObject();
        for (const char* textKey : {"text", "content", "summary", "thinking"}) {
            const QJsonValue textValue = nested.value(QLatin1String(textKey));
            if (textValue.isString() && !textValue.toString().isEmpty()) return textValue.toString();
        }
    }

    const QJsonValue details = object.value(QLatin1String("reasoning_details"));
    if (details.isArray()) {
        QString text;
        for (const QJsonValue& itemValue : details.toArray()) {
            const QJsonObject item = itemValue.toObject();
            const QString     type = item.value(QLatin1String("type")).toString();
            if (type.startsWith(QLatin1String("reasoning")) || type.isEmpty()) {
                text += item.value(QLatin1String("text")).toString();
            }
        }
        if (!text.isEmpty()) return text;
    }

    return QString();
}

UsageDelta parseUsageObject(const QJsonObject& usage) {
    UsageDelta result;

    qint64 input = asInt(usage.value("prompt_tokens"));
    if (input == 0) input = asInt(usage.value("input_tokens"));

    qint64 cached = asInt(usage.value("prompt_tokens_details").toObject().value("cached_tokens"));
    if (cached == 0) {
        cached = asInt(usage.value("input_tokens_details").toObject().value("cached_tokens"));
    }

    const qint64 cacheHit  = asInt(usage.value("prompt_cache_hit_tokens"));
    const qint64 cacheMiss = asInt(usage.value("prompt_cache_miss_tokens"));
    if (cacheHit > 0 || cacheMiss > 0) {
        cached = cacheHit;
        input  = cacheHit + cacheMiss;
    }

    const qint64 cacheRead     = asInt(usage.value("cache_read_input_tokens"));
    const qint64 cacheCreation = asInt(usage.value("cache_creation_input_tokens"));
    if (cacheRead > 0 || cacheCreation > 0) {
        cached = cacheRead;
        input += cacheRead + cacheCreation;
    }

    if (input < cached) input = cached;

    result.inputTokens      = input;
    result.cacheReadTokens  = cached;
    result.cacheWriteTokens = cacheCreation;
    result.outputTokens     = asInt(usage.value("completion_tokens"));
    if (result.outputTokens == 0) result.outputTokens = asInt(usage.value("output_tokens"));
    result.reasoningTokens = asInt(usage.value("completion_tokens_details").toObject().value("reasoning_tokens"));
    if (result.reasoningTokens == 0) {
        result.reasoningTokens = asInt(usage.value("output_tokens_details").toObject().value("reasoning_tokens"));
    }
    return result;
}

bool hasErrorObject(const QJsonObject& object) {
    const QJsonValue error = object.value(QLatin1String("error"));
    if (error.isObject()) return true;
    return error.isString() && !error.toString().isEmpty();
}

QString errorMessageOf(const QJsonObject& object, const QString& fallback) {
    const QJsonValue error = object.value(QLatin1String("error"));
    if (error.isObject()) {
        const QString message = error.toObject().value(QLatin1String("message")).toString();
        if (!message.isEmpty()) return message;
    } else if (error.isString() && !error.toString().isEmpty()) {
        return error.toString();
    }

    const QString message = object.value(QLatin1String("message")).toString();
    return message.isEmpty() ? fallback : message;
}

} // namespace mod::chatbot
