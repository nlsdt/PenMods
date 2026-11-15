#!/bin/sh
# 交叉编译 libflutter_elinux_wayland.so（带 embedder trace 日志）。
#
# 为什么要自己编：
#   - 官方 release 里的 .so 没有定义 ENABLE_ELINUX_EMBEDDER_LOG，
#     FLUTTER_LOG_LEVELS=TRACE 完全没输出，排查输入类问题时等于瞎子。
#   - 用宿主 wayland 1.26 头文件编出来的版本在设备上会因为
#     `undefined symbol: wl_proxy_marshal_flags` 直接起不来，必须用 1.16。
#
# 用法： tools/flutter-elinux/scripts/build_embedder.sh
set -eu

HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/env.sh"

[ -x "$FLUTTER_ELINUX_WORK/tc/zig-cxx" ] || {
    echo "先跑 setup_sysroot.sh" >&2
    exit 1
}

# flutter-embedded-linux 源码（含 embedder 与 vendored embedder.h）
if [ ! -d "$WORK_FEL" ]; then
    git clone --depth 1 https://github.com/sony/flutter-embedded-linux.git "$WORK_FEL"
fi

# 构建脚本要求引擎 .so 出现在源码树的 build/ 下
mkdir -p "$WORK_FEL/build"
cp -f "$WORK_ENGINE/libflutter_engine.so" "$WORK_FEL/build/"

PKG_CONFIG_LIBDIR=$WORK_PC "$CMAKE" -S "$WORK_FEL" -B "$WORK_BUILD" -G Ninja \
    -DCMAKE_TOOLCHAIN_FILE="$FLUTTER_ELINUX_WORK/toolchain.cmake" \
    -DBACKEND_TYPE=WAYLAND \
    -DBUILD_ELINUX_SO=ON \
    -DENABLE_ELINUX_EMBEDDER_LOG=ON \
    -DCMAKE_BUILD_TYPE=Release

# ninja 里写死了 /usr/bin/wayland-scanner（来自 pkg-config 变量）。换成 1.16 那个，
# 否则生成的协议代码会调用设备不存在的 wl_proxy_marshal_flags。
sed -i "s|/usr/bin/wayland-scanner|$FLUTTER_ELINUX_WORK/wayland-scanner-1.16|g" \
    "$WORK_BUILD/build.ninja"
rm -f "$WORK_FEL"/src/third_party/wayland/protocols/*-protocol.c \
      "$WORK_FEL"/src/third_party/wayland/protocols/*-protocol.h \
      "$WORK_FEL"/src/third_party/wayland/protocols/*-client-protocol.h

PKG_CONFIG_LIBDIR=$WORK_PC "$CMAKE" --build "$WORK_BUILD"

echo
echo "产物： $WORK_BUILD/libflutter_elinux_wayland.so"
echo "部署： adb push 到 bundle 的 lib/ 下（替换同名文件）"
