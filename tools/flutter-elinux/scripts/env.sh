# 共享路径与固定版本号。仅供本目录下其它脚本 source 使用。
#
# 所有下载物与中间产物都放在 $WORK 下（默认 <repo>/.tmp/flutter-elinux），
# 不污染仓库，也不依赖 /tmp（那个目录重启就没了）。

# 与本脚本配套的 Flutter SDK：克隆到 $FLUTTER_ELINUX_ROOT
#   git clone --depth 1 https://github.com/sony/flutter-elinux.git "$FLUTTER_ELINUX_ROOT"
FLUTTER_ELINUX_ROOT=${FLUTTER_ELINUX_ROOT:-$HOME/.local/opt/flutter-elinux}

# 引擎 / embedder 产物与 elf 仓库的固定版本（SDK 的 engine revision 必须与之一致）
FLUTTER_ENGINE_REVISION=${FLUTTER_ENGINE_REVISION:-cf56914b32}

# 工作目录
FLUTTER_ELINUX_WORK=${FLUTTER_ELINUX_WORK:-$PWD/.tmp/flutter-elinux}

# 目标三元组与 glibc 版本（设备合同：glibc 2.27）
TARGET_TRIPLE=${TARGET_TRIPLE:-aarch64-linux-gnu.2.27}

# 工具链
ZIG=${ZIG:-zig}
CMAKE=${CMAKE:-cmake}
NINJA=${NINJA:-ninja}
ADB=${ADB:-adb}

# 子目录约定
WORK_INCLUDE=$FLUTTER_ELINUX_WORK/include     # flutter 头文件（已做 C 兼容补丁）
WORK_SYSINC=$FLUTTER_ELINUX_WORK/sysinclude   # wayland / EGL / GLES / xkbcommon 头
WORK_LIBS=$FLUTTER_ELINUX_WORK/devlibs        # 从设备拉下来的运行库（仅用于链接）
WORK_PC=$FLUTTER_ELINUX_WORK/pc               # pkg-config 垫片
WORK_FEL=$FLUTTER_ELINUX_WORK/flutter-embedded-linux
WORK_ENGINE=$FLUTTER_ELINUX_WORK/engine       # 解包后的 elinux-arm64-release
WORK_BUILD=$FLUTTER_ELINUX_WORK/build         # embedder 的 cmake build 目录

ensure_dirs() {
    mkdir -p "$WORK_INCLUDE" "$WORK_SYSINC" "$WORK_LIBS" "$WORK_PC" "$WORK_ENGINE" "$WORK_BUILD"
}
