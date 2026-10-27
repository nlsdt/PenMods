// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include <cstdio>

namespace test {

inline int& checks() {
    static int value = 0;
    return value;
}

inline int& failures() {
    static int value = 0;
    return value;
}

} // namespace test

#define CHECK(condition)                                                                                               \
    do {                                                                                                               \
        ++test::checks();                                                                                              \
        if (!(condition)) {                                                                                            \
            ++test::failures();                                                                                        \
            std::fprintf(stderr, "FAIL %s:%d: %s\n", __FILE__, __LINE__, #condition);                                  \
        }                                                                                                              \
    } while (0)

#define CHECK_EQ(actual, expected)                                                                                     \
    do {                                                                                                               \
        ++test::checks();                                                                                              \
        const auto& _actual   = (actual);                                                                              \
        const auto& _expected = (expected);                                                                            \
        if (!(_actual == _expected)) {                                                                                 \
            ++test::failures();                                                                                        \
            std::fprintf(stderr, "FAIL %s:%d: %s != %s\n", __FILE__, __LINE__, #actual, #expected);                    \
        }                                                                                                              \
    } while (0)

inline int testSummary(const char* name) {
    if (test::failures() == 0) {
        std::printf("PASS %s (%d checks)\n", name, test::checks());
        return 0;
    }
    std::fprintf(stderr, "FAIL %s (%d/%d checks failed)\n", name, test::failures(), test::checks());
    return 1;
}
