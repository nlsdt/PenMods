// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include <chrono>
#include <cstdint>
#include <expected>
#include <optional>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

namespace mod::chatbot {

enum class ErrorCode {
    InvalidArgument,
    DatabaseOpen,
    DatabaseQuery,
    Schema,
    NotFound,
    Constraint,
};

struct Error {
    ErrorCode   code;
    std::string message;
};

template <class T>
using Result = std::expected<T, Error>;

inline std::unexpected<Error> fail(ErrorCode code, std::string message) {
    return std::unexpected(Error{code, std::move(message)});
}

inline std::int64_t nowMillis() {
    using namespace std::chrono;
    return duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
}

enum class EventKind {
    UserMessage,
    AssistantText,
    AssistantReasoning,
    ToolCall,
    ToolResult,
    RequestHeader,
    Unknown,
};

std::string_view              eventKindName(EventKind kind);
std::optional<EventKind>      eventKindFromName(std::string_view name);

struct NewEvent {
    std::string              turnId;
    EventKind                kind = EventKind::UserMessage;
    std::int64_t             time = 0; // 0 => use the append timestamp
    std::string              data;     // P1a: JSON text; zstd BLOB later
    bool                     truncated = false;
    std::optional<std::int64_t> origBytes;
};

struct SessionEvent {
    std::int64_t             seq = 0;
    std::string              turnId;
    EventKind                kind = EventKind::Unknown;
    std::int64_t             time = 0;
    std::string              data;
    bool                     truncated = false;
    std::optional<std::int64_t> origBytes;
};

// Token accounting for one completed request. Accumulated into the session row;
// the facade derives the per-run cache-hit statistics from the same numbers.
struct UsageCounters {
    std::int64_t input = 0;
    std::int64_t output = 0;
    std::int64_t reasoning = 0;
    std::int64_t cacheRead = 0;
    std::int64_t cacheWrite = 0;
};

struct SessionMeta {
    std::string              id;
    std::optional<std::string> parentId;
    std::string              title;
    std::optional<std::string> model;
    std::int64_t             createdAt = 0;
    std::int64_t             updatedAt = 0;
    std::optional<std::int64_t> compactedAt;
    std::optional<std::int64_t> archivedAt;
    std::int64_t             lastSeq = -1;
    std::int64_t             messageCount = 0;
    std::int64_t             tokensIn = 0;
    std::int64_t             tokensOut = 0;
    std::int64_t             tokensReasoning = 0;
    std::int64_t             tokensCacheRead = 0;
    std::int64_t             tokensCacheWrite = 0;
    double                   cost = 0;
};

struct SessionTurn {
    std::string              turnId;
    std::vector<SessionEvent> events;
};

} // namespace mod::chatbot
