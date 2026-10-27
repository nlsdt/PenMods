#!/bin/sh
# 本机测试：用 x86_64 Qt 编核心模块，不参与设备构建。
#
# 实际编译交给 tests/Makefile：模块对象只编一次、增量重编、-j 并行；
# SQLiteCpp 只编译成一个静态库，session 测试共用。
#
#   tests/run.sh                         # 全部
#   tests/run.sh test_protocol           # 只跑一个
#   SANITIZE=1 tests/run.sh              # ASan/UBSan（独立对象目录）
#   JOBS=4 tests/run.sh                  # 限制并行度
set -eu

cd "$(dirname "$0")/.."
ROOT=$(pwd)

OUT=${OUT:-build/tests}
SQLITECPP_DIR=${SQLITECPP_DIR:-.tmp/SQLiteCpp}
SANITIZE=${SANITIZE:-0}
JOBS=${JOBS:-$(nproc 2>/dev/null || echo 4)}

if [ ! -d "$SQLITECPP_DIR/include/SQLiteCpp" ]; then
    echo "缺少 SQLiteCpp 源码（$SQLITECPP_DIR）。" >&2
    echo "先执行：git clone --depth 1 --branch 3.4.0 https://github.com/SRombauts/SQLiteCpp .tmp/SQLiteCpp" >&2
    exit 1
fi

if ! pkg-config --exists Qt5Core; then
    echo "缺少 host Qt5Core 开发包（pkg-config Qt5Core）" >&2
    exit 1
fi

case "$OUT" in /*) ;; *) OUT="$ROOT/$OUT" ;; esac
SQLITECPP_DIR=$(cd "$SQLITECPP_DIR" && pwd)

if [ "$#" -gt 0 ]; then
    make -C tests -j"$JOBS" OUT="$OUT" SQLITECPP_DIR="$SQLITECPP_DIR" SANITIZE="$SANITIZE" TESTS="$*" run
else
    make -C tests -j"$JOBS" OUT="$OUT" SQLITECPP_DIR="$SQLITECPP_DIR" SANITIZE="$SANITIZE" run
fi
