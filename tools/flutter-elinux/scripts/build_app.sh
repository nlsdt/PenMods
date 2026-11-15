#!/bin/sh
# 把一个 Flutter 工程打成可以直接在笔上跑的 bundle 目录。
#
#   bundle/
#     penmods-flutter                # 我们的 runner
#     lib/libapp.so                  # Dart AOT
#     lib/libflutter_elinux_wayland.so
#     lib/libflutter_engine.so
#     data/icudtl.dat
#     data/flutter_assets/...
#
# 用法： tools/flutter-elinux/scripts/build_app.sh <flutter 工程目录> <输出目录>
set -eu

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)
. "$HERE/env.sh"

PROJ=${1:?用法: build_app.sh <flutter 工程目录> <输出目录>}
OUT=${2:?用法: build_app.sh <flutter 工程目录> <输出目录>}

[ -x "$FLUTTER_ELINUX_ROOT/bin/flutter-elinux" ] || {
    echo "找不到 flutter-elinux SDK：$FLUTTER_ELINUX_ROOT" >&2
    echo "  git clone --depth 1 https://github.com/sony/flutter-elinux.git $FLUTTER_ELINUX_ROOT" >&2
    exit 1
}

# 工程必须有 elinux/ 脚手架（flutter-elinux create 生成）。如果只有 pubspec + lib，
# 就用 create 生成一份临时工程，再把源码覆盖过去——这样仓库里不必放脚手架。
if [ ! -d "$PROJ/elinux" ]; then
    echo "[build_app] $PROJ 没有 elinux/，临时生成脚手架"
    NAME=$(sed -n 's/^name:[[:space:]]*//p' "$PROJ/pubspec.yaml" | head -1)
    GEN=$FLUTTER_ELINUX_WORK/appgen
    rm -rf "$GEN"
    PATH="$FLUTTER_ELINUX_ROOT/bin:$PATH" \
        flutter-elinux create --project-name "${NAME:-penmods_app}" --org com.penmods "$GEN" >/dev/null
    cp "$PROJ/pubspec.yaml" "$GEN/pubspec.yaml"
    rm -rf "$GEN/lib" && cp -a "$PROJ/lib" "$GEN/lib"
    PROJ=$GEN
fi

# 这一条命令会在 CMake 链接阶段失败（用宿主编译器链接 arm64 引擎），
# 但只要看到 "Failed to cmake build" 就说明 Dart AOT 与资源已经产出完毕。
# 这是刻意的：我们不要它的 runner，只要 AOT + assets。
(
    cd "$PROJ"
    PATH="$FLUTTER_ELINUX_ROOT/bin:$PATH" \
        flutter-elinux build elinux --release --target-arch=arm64 || true
)

EPHEMERAL=$PROJ/elinux/flutter/ephemeral
ASSETS=$PROJ/build/elinux/flutter_assets
[ -f "$EPHEMERAL/libapp.so" ] || { echo "AOT 没有产出：$EPHEMERAL/libapp.so" >&2; exit 1; }
[ -d "$ASSETS" ]               || { echo "资源没有产出：$ASSETS" >&2; exit 1; }

rm -rf "$OUT"
mkdir -p "$OUT/lib" "$OUT/data"
cp "$EPHEMERAL/libapp.so" "$OUT/lib/"
cp "$EPHEMERAL/icudtl.dat" "$OUT/data/"
cp -a "$ASSETS" "$OUT/data/flutter_assets"

# 引擎与 embedder：优先用自己编的（带 trace），否则退回官方产物
if [ -f "$WORK_BUILD/libflutter_elinux_wayland.so" ]; then
    cp "$WORK_BUILD/libflutter_elinux_wayland.so" "$OUT/lib/"
else
    cp "$WORK_ENGINE/libflutter_elinux_wayland.so" "$OUT/lib/"
fi
cp "$WORK_ENGINE/libflutter_engine.so" "$OUT/lib/"

"$HERE/build_runner.sh" "$OUT/penmods-flutter"
chmod +x "$OUT/penmods-flutter"

du -sh "$OUT"
