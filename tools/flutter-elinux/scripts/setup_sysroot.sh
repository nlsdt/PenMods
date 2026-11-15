#!/bin/sh
# 准备交叉编译 flutter-elinux embedder 所需的一切：
#   1. 下载固定版本的 elinux 引擎 / 头文件产物
#   2. 给 flutter_elinux.h 打 C 兼容补丁（源码里是 C++ 写法）
#   3. 拉取设备上的运行库（仅用于链接，保证 soname 与设备一致）
#   4. 准备 wayland 1.16 的 scanner 与头文件（设备没有 wl_proxy_marshal_flags）
#   5. 生成 pkg-config 垫片与 zig 编译器包装、cmake toolchain 文件
#
# 用法： tools/flutter-elinux/scripts/setup_sysroot.sh
set -eu

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)
REPO=$(cd "$ROOT/../.." && pwd)
. "$HERE/env.sh"
ensure_dirs

REL_URL=https://github.com/sony/flutter-embedded-linux/releases/download/$FLUTTER_ENGINE_REVISION

say() { printf '\033[36m[setup]\033[0m %s\n' "$*"; }

# ---------------------------------------------------------------- 1. 产物
if [ ! -f "$WORK_ENGINE/libflutter_engine.so" ]; then
    say "下载 elinux-arm64-release.zip"
    curl -fL -o "$FLUTTER_ELINUX_WORK/arm64.zip" "$REL_URL/elinux-arm64-release.zip"
    rm -rf "$WORK_ENGINE" && mkdir -p "$WORK_ENGINE"
    unzip -qo "$FLUTTER_ELINUX_WORK/arm64.zip" -d "$WORK_ENGINE"
fi

if [ ! -f "$WORK_INCLUDE/flutter_elinux.h" ]; then
    say "下载 elinux-common.zip（头文件 / icudtl / cpp wrapper）"
    curl -fL -o "$FLUTTER_ELINUX_WORK/common.zip" "$REL_URL/elinux-common.zip"
    unzip -qo "$FLUTTER_ELINUX_WORK/common.zip" -d "$FLUTTER_ELINUX_WORK/common"
    cp "$FLUTTER_ELINUX_WORK"/common/*.h "$WORK_INCLUDE"/

    # 上游头是 C++ 写法（枚举不带 tag），我们 runner 是纯 C，必须打补丁。
    # 补丁放在 compat/ 里而不是内联 sed，这样改动可 review；打不上就失败，
    # 免得升级产物后悄悄编出一个不对的头。
    patch -p1 -d "$WORK_INCLUDE" < "$ROOT/compat/flutter_elinux-c.patch" \
        || { echo "compat/flutter_elinux-c.patch 打不上，上游结构体可能变了" >&2; exit 1; }
fi

# ------------------------------------------------------- 2. 设备运行库
if [ ! -f "$WORK_LIBS/libwayland-client.so.0" ]; then
    say "从设备拉取运行库（用于链接）"
    for so in libwayland-client.so.0 libwayland-cursor.so.0 libwayland-egl.so.1 \
              libxkbcommon.so.0 libEGL.so.1 libGLESv2.so.2 libstdc++.so.6 \
              libgcc_s.so.1 libfontconfig.so.1 libfreetype.so.6 libexpat.so.1 \
              libz.so.1 libpng16.so.16; do
        "$ADB" pull "/usr/lib/$so" "$WORK_LIBS/" 2>/dev/null \
            || "$ADB" pull "/lib/$so" "$WORK_LIBS/" 2>/dev/null \
            || echo "  (skip $so)"
    done
    # 生成 -l<name> 需要的无版本符号链接
    (
        cd "$WORK_LIBS"
        link() { [ -e "$1" ] && ln -sf "$1" "$2"; return 0; }
        link libwayland-client.so.0 libwayland-client.so
        link libwayland-cursor.so.0 libwayland-cursor.so
        link libwayland-egl.so.1    libwayland-egl.so
        link libxkbcommon.so.0      libxkbcommon.so
        link libEGL.so.1            libEGL.so
        link libGLESv2.so.2         libGLESv2.so
        link libstdc++.so.6         libstdc++.so
        link libgcc_s.so.1          libgcc_s.so
        link libfontconfig.so.1     libfontconfig.so
        link libfreetype.so.6       libfreetype.so
        link libexpat.so.1          libexpat.so
        link libz.so.1              libz.so
        link libpng16.so.16         libpng.so
    )
fi

# --------------------------------------------- 3. wayland 1.16 头与 scanner
if [ ! -x "$FLUTTER_ELINUX_WORK/wayland-scanner-1.16" ]; then
    say "构建 wayland 1.16 的 scanner（设备缺 wl_proxy_marshal_flags）"
    (
        cd "$FLUTTER_ELINUX_WORK"
        [ -d wayland-1.16.0 ] || {
            curl -fL -o wayland-1.16.0.tar.gz \
                "https://gitlab.freedesktop.org/wayland/wayland/-/archive/1.16.0/wayland-1.16.0.tar.gz"
            tar xzf wayland-1.16.0.tar.gz
        }
        cd wayland-1.16.0
        : > src/config.h
        gcc -O2 -I src -o "$FLUTTER_ELINUX_WORK/wayland-scanner-1.16" \
            src/scanner.c src/wayland-util.c -lexpat
    )
fi

if [ ! -f "$WORK_SYSINC/wayland-client-protocol.h" ]; then
    say "准备 wayland / EGL / GLES / xkbcommon 头文件"
    W=$FLUTTER_ELINUX_WORK/wayland-1.16.0
    cp "$W"/src/wayland-client.h "$W"/src/wayland-client-core.h "$W"/src/wayland-util.h "$WORK_SYSINC"/
    cp "$W"/cursor/wayland-cursor.h "$WORK_SYSINC"/
    # wayland-version.h 上游由 meson 生成，源码树里没有；用项目里固定 1.16 的那份
    cp "$ROOT/compat/wayland-version.h" "$WORK_SYSINC/wayland-version.h"
    # 用 1.16 scanner 生成核心协议头：生成的代码走 wl_proxy_marshal* 老 API
    "$FLUTTER_ELINUX_WORK/wayland-scanner-1.16" client-header \
        "$W/protocol/wayland.xml" "$WORK_SYSINC/wayland-client-protocol.h"
    # 这些头是架构无关的，可以取宿主机的
    cp /usr/include/wayland-egl.h /usr/include/wayland-egl-core.h "$WORK_SYSINC"/
    cp -a /usr/include/xkbcommon /usr/include/EGL /usr/include/KHR \
          /usr/include/GLES2 /usr/include/GLES3 "$WORK_SYSINC"/
    mkdir -p "$WORK_SYSINC/linux"
    cp /usr/include/linux/input.h /usr/include/linux/input-event-codes.h \
       /usr/include/linux/types.h /usr/include/linux/limits.h "$WORK_SYSINC/linux"/
fi

# ------------------------------------------------------ 4. pkg-config 垫片
say "生成 pkg-config 垫片与工具链文件"
for m in egl xkbcommon wayland-protocols wayland-client wayland-cursor wayland-egl glesv2; do
    p=$(pkg-config --variable=pcfiledir "$m" 2>/dev/null)/$m.pc
    [ -f "$p" ] || { echo "  缺失 $m.pc，跳过"; continue; }
    # Libs 全部清空（不能链接宿主 x86 库），Cflags 指向自备 sysinclude
    awk -v inc="$WORK_SYSINC" '
        /^Libs(\.private)?:/ { print ""; next }
        /^Cflags:/          { print "Cflags: -I" inc; next }
        { print }
    ' "$p" > "$WORK_PC/$m.pc"
done

mkdir -p "$FLUTTER_ELINUX_WORK/tc"
cat > "$FLUTTER_ELINUX_WORK/tc/zig-c" <<EOF
#!/bin/sh
exec $ZIG cc -target $TARGET_TRIPLE "\$@"
EOF
cat > "$FLUTTER_ELINUX_WORK/tc/zig-cxx" <<EOF
#!/bin/sh
exec $ZIG c++ -target $TARGET_TRIPLE "\$@"
EOF
chmod +x "$FLUTTER_ELINUX_WORK/tc/zig-c" "$FLUTTER_ELINUX_WORK/tc/zig-cxx"

sed -e "s|@WORK@|$FLUTTER_ELINUX_WORK|g" \
    -e "s|@SYSINC@|$WORK_SYSINC|g" \
    -e "s|@LIBS@|$WORK_LIBS|g" \
    "$ROOT/toolchain.cmake.in" > "$FLUTTER_ELINUX_WORK/toolchain.cmake"

say "完成。下一步：build_embedder.sh"
