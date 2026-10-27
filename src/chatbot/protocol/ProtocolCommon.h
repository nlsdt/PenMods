// SPDX-License-Identifier: GPL-3.0-only
/*
 * Copyright (C) 2022-present, PenUniverse.
 * This file is part of the PenMods open source project.
 */

#pragma once

#include "StreamEvent.h"

#include <QJsonObject>
#include <QJsonValue>
#include <QString>

namespace mod::chatbot {

// Provider payloads disagree on nearly every reasoning field name; this is the
// exact precedence list the old backend accepted.
QString extractReasoningText(const QJsonObject& object);

// Normalises the usage object of both protocols into UsageDelta. Returns an
// all-zero struct when the payload carries no usage at all.
UsageDelta parseUsageObject(const QJsonObject& usage);

// True while an object carries an "error" member (object or non-empty string).
bool hasErrorObject(const QJsonObject& object);

// Human-readable message from {"error":{"message":...}} or {"message":...}.
QString errorMessageOf(const QJsonObject& object, const QString& fallback = QString());

} // namespace mod::chatbot
