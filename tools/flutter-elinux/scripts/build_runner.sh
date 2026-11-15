#!/bin/sh
# 交叉编译 PenMods 的 Flutter runner（tools/flutter-elinux/runner/main.c）。
#
# 产出一个约 19 KB 的可执行文件，负责：读 bundle、建引擎与视图、跑事件循环。
# 它刻意不用官方那套 C++ wrapper + CMake（那需要完整的 arm64 sysroot），
# 只用 flutter_elinux.h 的 C API。
#
# 用法： tools/flutter-elinux/scripts/build_runner.sh <输出路径>
set -eu

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)
. "$HERE/env.sh"

OUT=${1:-$FLUTTER_ELINUX_WORK/penmods-flutter}

[ -f "$WORK_INCLUDE/flutter_elinux.h" ] || {
    echo "先跑 setup_sysroot.sh" >&2
    exit 1
}

EMBEDDER=${EMBEDDER:-$WORK_BUILD/libflutter_elinux_wayland.so}
[ -f "$EMBEDDER" ] || { echo "找不到 embedder: $EMBEDDER（先跑 build_embedder.sh）" >&2; exit 1; }

"$ZIG" cc -target "$TARGET_TRIPLE" -O2 \
    -I "$WORK_INCLUDE" \
    -o "$OUT" \
    "$ROOT/runner/main.c" \
    -Wl,--no-as-needed "$EMBEDDER" \
    "$WORK_LIBS/libwayland-client.so.0" \
    "$WORK_LIBS/libwayland-cursor.so.0" \
    "$WORK_LIBS/libwayland-egl.so.1" \
    "$WORK_LIBS/libxkbcommon.so.0" \
    "$WORK_LIBS/libEGL.so.1" \
    "$WORK_LIBS/libGLESv2.so.2" \
    -Wl,-rpath,'$ORIGIN/lib' \
    -Wl,--allow-shlib-undefined \
    -lpthread -ldl -lm

echo "产物： $OUT"
