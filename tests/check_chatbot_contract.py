#!/usr/bin/env python3
"""Compare the QML contract of the frozen Backend ChatBot with ChatBotV2.

The goal of the rewrite is exact parity for Q_PROPERTY / Q_INVOKABLE / signals.
Run from the repository root:

    python3 tests/check_chatbot_contract.py

Exit code 1 when a property, invokable or signal is missing (or extra) in the new
facade. The two files deliberately do not share a base class, so this is the only
mechanical check before deleting Backend.h.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
NEW = ROOT / "src/chatbot/facade/ChatBot.h"

# Backend.h is gone from the tree. Read the frozen contract from git so this
# check still works after the switch (HEAD must still contain it until the
# deletion is committed; afterwards pass --base <rev>).
import argparse
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("--base", default="HEAD", help="git revision that still has src/chatbot/Backend.h")
args = parser.parse_args()
OLD_TEXT = subprocess.run(
    ["git", "show", f"{args.base}:src/chatbot/Backend.h"],
    cwd=ROOT, capture_output=True, text=True, check=True).stdout


def properties(text: str) -> set[str]:
    # Q_PROPERTY(QString apiKey READ ... NOTIFY apiKeyChanged)
    return set(re.findall(r"Q_PROPERTY\(\s*[\w:<>]+\s+(\w+)\s+READ\b", text))


def invokables(text: str) -> set[str]:
    return set(re.findall(r"Q_INVOKABLE\s+[\w:<>]+\s+(\w+)\s*\(", text))


def signals(text: str) -> set[str]:
    body = text.split("signals:", 1)[1].split("private:", 1)[0]
    # Collapse line breaks so `void\n    tavilySearchFinished(` still matches.
    collapsed = re.sub(r"\s+", " ", body)
    return set(re.findall(r"\bvoid\s+(\w+)\s*\(", collapsed))


def compare(label: str, old: set[str], new: set[str]) -> list[str]:
    problems: list[str] = []
    missing = sorted(old - new)
    extra = sorted(new - old)
    print(f"{label}: old={len(old)} new={len(new)}")
    if missing:
        print(f"  missing in new ({len(missing)}): {', '.join(missing)}")
        problems.append(f"{label} missing")
    if extra:
        print(f"  extra in new ({len(extra)}): {', '.join(extra)}")
        problems.append(f"{label} extra")
    return problems


def main() -> int:
    old = OLD_TEXT
    new = NEW.read_text(encoding="utf-8")

    problems: list[str] = []
    problems += compare("Q_PROPERTY", properties(old), properties(new))
    problems += compare("Q_INVOKABLE", invokables(old), invokables(new))
    problems += compare("signals", signals(old), signals(new))

    if problems:
        print("CONTRACT MISMATCH")
        return 1
    print("contract ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
