// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/model/ModelRegistry.h"
#include "chatbot/model/PromptStore.h"
#include "test_main.h"

#include <QJsonArray>
#include <QJsonObject>
#include <QString>

using namespace mod::chatbot;

namespace {

QJsonObject modelInput(const char* id, const char* modelId, const char* endpoint) {
    QJsonObject input;
    input.insert(QStringLiteral("id"), QString::fromUtf8(id));
    input.insert(QStringLiteral("modelId"), QString::fromUtf8(modelId));
    input.insert(QStringLiteral("endpoint"), QString::fromUtf8(endpoint));
    input.insert(QStringLiteral("name"), QString::fromUtf8(id));
    return input;
}

} // namespace

int main() {
    // ------------------------------------------------------------ defaults
    {
        const ModelRegistry registry = ModelRegistry::createDefault(
            QStringLiteral("https://api.example/v1/chat/completions"),
            QStringLiteral("sk-test"),
            QStringLiteral("deepseek-chat"),
            0.5,
            QStringLiteral("describe"));

        CHECK_EQ(registry.ids().size(), 1);
        const ActiveModel active = registry.active();
        CHECK(active.endpoint == QStringLiteral("https://api.example/v1/chat/completions"));
        CHECK(active.apiKey == QStringLiteral("sk-test"));
        CHECK(active.modelId == QStringLiteral("deepseek-chat"));
        CHECK(active.apiProtocol == QStringLiteral("chat_completions"));
        CHECK(qAbs(active.temperature - 0.5) < 1e-9);
        CHECK(active.capabilities.text);
        CHECK(!active.capabilities.vision);
        CHECK(active.proxyVisionPrompt == QStringLiteral("describe"));
    }

    // ------------------------------------------------------- validation
    {
        auto registry = ModelRegistry::createDefault("e", "k", "m", 0.7, "p");
        QString error;
        CHECK(!registry.upsert(modelInput("", "m2", "e"), &error));
        CHECK(!error.isEmpty());
        CHECK(!registry.upsert(modelInput("a", "", "e")));
        CHECK(!registry.upsert(modelInput("a", "m2", "")));
        CHECK_EQ(registry.ids().size(), 1);
    }

    // ------------------------------------------------------------ add/update
    {
        auto registry = ModelRegistry::createDefault("e", "k", "m", 0.7, "p");

        QJsonObject input = modelInput("m2", "model-2", "https://x");
        input.insert(QStringLiteral("apiProtocol"), QStringLiteral("weird"));
        input.insert(QStringLiteral("reasoningEffort"), QStringLiteral("max"));
        input.insert(QStringLiteral("temperature"), 0.2);
        input.insert(QStringLiteral("extraParams"), QStringLiteral(R"({"top_p":0.9})"));
        input.insert(
            QStringLiteral("capabilities"),
            QJsonObject{{QStringLiteral("vision"), true}, {QStringLiteral("toolCall"), true}});
        CHECK(registry.upsert(input));

        const ActiveModel active = registry.active();
        CHECK_EQ(registry.ids().size(), 2);
        // Adding a model does not switch the active one.
        CHECK(active.id == QStringLiteral("m"));

        CHECK(registry.setActive(QStringLiteral("m2")));
        const ActiveModel m2 = registry.active();
        CHECK(m2.apiProtocol == QStringLiteral("chat_completions")); // normalized
        CHECK(m2.reasoningEffort.isEmpty());                         // invalid effort dropped
        CHECK(m2.capabilities.vision);
        CHECK(m2.capabilities.toolCall);
        CHECK(!m2.capabilities.reasoning);
        CHECK(qAbs(m2.temperature - 0.2) < 1e-9);
        CHECK(m2.extraParams.value(QStringLiteral("top_p")).toDouble() == 0.9);

        // Updating the same id replaces in place.
        QJsonObject update = modelInput("m2", "model-2b", "https://y");
        CHECK(registry.upsert(update));
        CHECK_EQ(registry.ids().size(), 2);
        CHECK(registry.modelJson(QStringLiteral("m2")).value(QStringLiteral("modelId")).toString()
              == QStringLiteral("model-2b"));
    }

    // ------------------------------------------------------ constructor filter
    {
        QJsonObject section;
        QJsonArray  models;
        models.append(modelInput("ok", "m", "e"));
        models.append(QJsonObject{{QStringLiteral("id"), QStringLiteral("broken")}});
        section.insert(QStringLiteral("models"), models);
        section.insert(QStringLiteral("activeModelId"), QStringLiteral("missing"));

        const ModelRegistry registry(section);
        CHECK_EQ(registry.ids().size(), 1);
        CHECK(registry.activeModelId() == QStringLiteral("ok"));
        CHECK(registry.active().id == QStringLiteral("ok"));

        const ModelRegistry empty(QJsonObject{});
        CHECK(empty.ids().isEmpty());
        CHECK(empty.active().id.isEmpty());
        CHECK(empty.activeModelJson().isEmpty());
    }

    // ------------------------------------------------------------- remove
    {
        auto registry = ModelRegistry::createDefault("e", "k", "m", 0.7, "p");

        QJsonObject second = modelInput("m2", "model-2", "https://x");
        second.insert(QStringLiteral("proxyVisionModelId"), QStringLiteral("m"));
        CHECK(registry.upsert(second));
        CHECK(registry.upsert(modelInput("m3", "model-3", "https://z")));

        // Removing the active model falls back to the first remaining one.
        CHECK(registry.setActive(QStringLiteral("m3")));
        CHECK(registry.remove(QStringLiteral("m3")));
        CHECK(registry.activeModelId() == QStringLiteral("m"));
        CHECK(!registry.remove(QStringLiteral("m3")));

        // Removing a model clears other models' proxy references to it.
        QJsonObject third = modelInput("m4", "model-4", "https://w");
        third.insert(QStringLiteral("proxyVisionModelId"), QStringLiteral("m2"));
        CHECK(registry.upsert(third));
        CHECK(registry.remove(QStringLiteral("m2")));
        CHECK(registry.modelJson(QStringLiteral("m4"))
                  .value(QStringLiteral("proxyVisionModelId"))
                  .toString()
                  .isEmpty());
    }

    // ------------------------------------------------------------- prompts
    {
        PromptStore store = PromptStore::createDefault(QStringLiteral("You are helpful."));
        CHECK_EQ(store.ids().size(), 1);
        CHECK(store.activeContent() == QStringLiteral("You are helpful."));
        CHECK(store.activePromptJson().value(QStringLiteral("isActive")).toBool());

        QString error;
        CHECK(!store.upsert(QJsonObject{{QStringLiteral("name"), QStringLiteral("x")}}, &error));
        CHECK(!error.isEmpty());
        CHECK(!store.upsert(QJsonObject{{QStringLiteral("id"), QStringLiteral("x")}}));

        CHECK(store.upsert(
            QJsonObject{{QStringLiteral("id"), QStringLiteral("tutor")},
                        {QStringLiteral("name"), QStringLiteral("Tutor")},
                        {QStringLiteral("content"), QStringLiteral("Teach.")}}));
        CHECK_EQ(store.ids().size(), 2);
        CHECK(store.setActive(QStringLiteral("tutor")));
        CHECK(store.activeContent() == QStringLiteral("Teach."));
        CHECK(store.activeName() == QStringLiteral("Tutor"));
        CHECK(!store.setActive(QStringLiteral("nope")));

        // Updating keeps the list stable.
        CHECK(store.upsert(
            QJsonObject{{QStringLiteral("id"), QStringLiteral("tutor")},
                        {QStringLiteral("name"), QStringLiteral("Tutor 2")},
                        {QStringLiteral("content"), QStringLiteral("Teach 2.")}}));
        CHECK_EQ(store.ids().size(), 2);
        CHECK(store.activeContent() == QStringLiteral("Teach 2."));

        // Removing the active prompt activates the first remaining one.
        CHECK(store.remove(QStringLiteral("tutor")));
        CHECK(store.activePromptId() == QStringLiteral("default"));
        CHECK(!store.remove(QStringLiteral("tutor")));

        const PromptStore roundTrip(store.toJson());
        CHECK(roundTrip.activePromptId() == QStringLiteral("default"));
        CHECK(roundTrip.activeContent() == QStringLiteral("You are helpful."));
    }

    return testSummary("models");
}
