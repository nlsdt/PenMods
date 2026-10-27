// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#include "chatbot/session/SessionStore.h"
#include "test_main.h"

#include <sqlite3.h>

#include <cstdint>
#include <filesystem>
#include <string>
#include <vector>

#include <unistd.h>

using namespace mod::chatbot;

int main() {
    auto opened = SessionStore::open(":memory:");
    CHECK(opened.has_value());
    if (!opened) {
        return testSummary("session_store");
    }
    auto& store = *opened;

    CHECK(!store->createSession("").has_value());

    auto created = store->createSession("s1", "Title", "model-a", 1000);
    CHECK(created.has_value());
    if (!created) {
        return testSummary("session_store");
    }
    CHECK_EQ(created->id, std::string("s1"));
    CHECK_EQ(created->title, std::string("Title"));
    CHECK_EQ(created->model.value_or(""), std::string("model-a"));
    CHECK_EQ(created->lastSeq, std::int64_t{-1});

    std::vector<NewEvent> events;
    events.push_back(NewEvent{"u1", EventKind::UserMessage, 1001, R"({"text":"hi"})", false, std::nullopt});
    events.push_back(NewEvent{"a1", EventKind::AssistantReasoning, 1002, R"({"text":"think"})", false, std::nullopt});
    events.push_back(NewEvent{"a1", EventKind::AssistantText, 1003, R"({"text":"hello"})", false, std::nullopt});
    events.push_back(NewEvent{"a1", EventKind::ToolCall, 1004, R"({"name":"search"})", true, 42});

    auto appended = store->appendEvents("s1", events, 2000);
    CHECK(appended.has_value());
    if (!appended) {
        return testSummary("session_store");
    }
    CHECK_EQ(appended->size(), std::size_t{4});
    CHECK_EQ((*appended)[0].seq, std::int64_t{0});
    CHECK_EQ((*appended)[3].seq, std::int64_t{3});
    CHECK_EQ((*appended)[3].truncated, true);
    CHECK_EQ((*appended)[3].origBytes.value_or(0), std::int64_t{42});

    auto meta = store->getSession("s1");
    CHECK(meta.has_value());
    CHECK_EQ(meta->lastSeq, std::int64_t{3});
    CHECK_EQ(meta->messageCount, std::int64_t{4});
    CHECK_EQ(meta->updatedAt, std::int64_t{2000});

    auto loaded = store->loadEvents("s1");
    CHECK(loaded.has_value());
    CHECK_EQ(loaded->size(), std::size_t{4});
    if (loaded) {
        CHECK_EQ((*loaded)[0].kind, EventKind::UserMessage);
        CHECK_EQ((*loaded)[2].kind, EventKind::AssistantText);
        CHECK_EQ((*loaded)[3].data, std::string(R"({"name":"search"})"));
    }

    auto turns = store->loadTurns("s1");
    CHECK(turns.has_value());
    CHECK_EQ(turns->size(), std::size_t{2});
    if (turns) {
        CHECK_EQ((*turns)[0].turnId, std::string("u1"));
        CHECK_EQ((*turns)[0].events.size(), std::size_t{1});
        CHECK_EQ((*turns)[1].turnId, std::string("a1"));
        CHECK_EQ((*turns)[1].events.size(), std::size_t{3});
    }

    CHECK(store->addUsage("s1", UsageCounters{10, 4, 2, 3, 1}).has_value());
    CHECK(store->addUsage("s1", UsageCounters{5, 1, 0, 0, 0}).has_value());
    CHECK(store->addUsage("s1", UsageCounters{}).has_value());
    CHECK(!store->addUsage("missing", UsageCounters{1, 0, 0, 0, 0}).has_value());
    auto usageMeta = store->getSession("s1");
    CHECK(usageMeta.has_value());
    if (usageMeta) {
        CHECK_EQ(usageMeta->tokensIn, std::int64_t{15});
        CHECK_EQ(usageMeta->tokensOut, std::int64_t{5});
        CHECK_EQ(usageMeta->tokensReasoning, std::int64_t{2});
        CHECK_EQ(usageMeta->tokensCacheRead, std::int64_t{3});
        CHECK_EQ(usageMeta->tokensCacheWrite, std::int64_t{1});
    }

    CHECK(store->renameSession("s1", "Renamed", 3000).has_value());
    auto renamed = store->getSession("s1");    CHECK(renamed.has_value());
    CHECK_EQ(renamed->title, std::string("Renamed"));

    auto listed = store->listSessions();
    CHECK(listed.has_value());
    CHECK_EQ(listed->size(), std::size_t{1});

    auto lastTurn = store->lastUserTurnId("s1");
    CHECK(lastTurn.has_value());
    CHECK(lastTurn->has_value());
    CHECK_EQ(lastTurn->value_or(""), std::string("u1"));
    auto missingTurn = store->lastUserTurnId("missing");
    CHECK(missingTurn.has_value());
    CHECK(!missingTurn->has_value());

    // Tail deletion: keep seq 0..1, free the rest for reuse.
    CHECK(!store->deleteEventsFrom("s1", -1).has_value());
    CHECK(store->deleteEventsFrom("s1", 2, 4000).has_value());
    auto truncated = store->getSession("s1");
    CHECK(truncated.has_value());
    CHECK_EQ(truncated->lastSeq, std::int64_t{1});
    CHECK_EQ(truncated->messageCount, std::int64_t{2});
    CHECK_EQ(truncated->updatedAt, std::int64_t{4000});

    auto reused = store->appendEvents(
        "s1",
        {NewEvent{"u1", EventKind::AssistantText, 4001, R"({"text":"again"})", false, std::nullopt}},
        4001);
    CHECK(reused.has_value());
    if (reused) {
        CHECK_EQ(reused->size(), std::size_t{1});
        CHECK_EQ((*reused)[0].seq, std::int64_t{2});
    }

    CHECK(!store->appendEvents("missing", events).has_value());

    CHECK(store->deleteSession("s1").has_value());
    CHECK(!store->getSession("s1").has_value());
    CHECK(!store->deleteSession("s1").has_value());

    // Schema downgrade guard: a database written by a newer build is rejected.
    {
        const auto path = std::filesystem::temp_directory_path()
                          / ("penmods-schema-" + std::to_string(static_cast<long long>(getpid())) + ".db");
        std::filesystem::remove(path);
        CHECK(SessionStore::open(path.string()).has_value());

        sqlite3* raw = nullptr;
        CHECK_EQ(sqlite3_open(path.string().c_str(), &raw), SQLITE_OK);
        CHECK_EQ(sqlite3_exec(raw, "PRAGMA user_version = 99", nullptr, nullptr, nullptr), SQLITE_OK);
        sqlite3_close(raw);

        auto newer = SessionStore::open(path.string());
        CHECK(!newer.has_value());
        if (!newer) CHECK(newer.error().code == ErrorCode::Schema);

        std::filesystem::remove(path);
        std::filesystem::remove(path.string() + "-wal");
        std::filesystem::remove(path.string() + "-shm");
    }

    return testSummary("session_store");
}
