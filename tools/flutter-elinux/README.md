# flutter-elinux on PenMods

在笔上跑 Flutter（Material 3）应用所需的宿主 runner、交叉编译脚本与诊断工具。
完整背景、实测数据与踩坑记录见 [`doc/FLUTTER_ELINUX_SPIKE.md`](../../doc/FLUTTER_ELINUX_SPIKE.md)。

定位：**插件应用运行时**。插件 = 一个 Flutter bundle，PenMods 只负责 `exec` / 等待退出 / 回收，
不接管窗口管理（Weston 没有任务切换 UI）。跨进程无法 hook，所以它补的是"崩溃隔离"，
取代不了 Hook API。

## 快速开始

```sh
ALL=tools/flutter-elinux/scripts

# 0) 一次性：Flutter SDK（约 1.5 GB，首次运行还会拉 Dart SDK）
git clone --depth 1 https://github.com/sony/flutter-elinux.git ~/.local/opt/flutter-elinux

# 1) 一次性：引擎产物 / 头文件 / 设备库 / wayland 1.16 / pkg-config 垫片
$ALL/setup_sysroot.sh

# 2) embedder（带 trace 日志，改用 wayland 1.16 API）
$ALL/build_embedder.sh

# 3) 把任意 Flutter 工程打成 bundle
$ALL/build_app.sh tools/flutter-elinux/demo .tmp/bundle
```

部署与运行：

```sh
adb push .tmp/bundle /userdisk/flutter        # 或 tar 过去，约 30 MB
adb shell 'cd /userdisk/flutter && \
  XDG_RUNTIME_DIR=/var/run WAYLAND_DISPLAY=wayland-0 \
  LD_LIBRARY_PATH=/userdisk/flutter/lib \
  ./penmods-flutter /userdisk/flutter 800 480'
```

## 目录

| 路径 | 作用 |
|---|---|
| `runner/main.c` | 19 KB 的宿主 runner，只用 `flutter_elinux.h` 的 C API |
| `demo/` | MD3 组件样张（按钮 / 开关 / 输入框 / 列表 / 对话框 / SnackBar） |
| `diag/pointerd.c` | 让合成器提前持有指针设备的诊断工具（排查"收不到输入"） |
| `scripts/setup_sysroot.sh` | 一次性准备交叉编译环境 |
| `scripts/build_embedder.sh` | 编译 `libflutter_elinux_wayland.so` |
| `scripts/build_runner.sh` | 编译 runner |
| `scripts/build_app.sh` | 打包 bundle |
| `toolchain.cmake.in` | 由 `setup_sysroot.sh` 填充成实际的 cmake toolchain |

中间产物默认落在 `.tmp/flutter-elinux/`（不进 git，也不放 `/tmp`——那里重启就没了）。

## 内容带（"黑边"）

笔的界面不铺满整块屏：宿主自带 UI 只占中间一条（YDP03X 实测 800×480 屏的
**y=127..353**，上下各 127 px 纯黑）。guest 应用跟随同一版式才不突兀，但**不能靠缩小窗口**
——Weston 不会把 800×227 的窗口居中（实测落在 y≈99），下面会露出宿主页面。

做法：窗口仍全屏 800×480，把内容带作为运行时参数下发给 Dart：

```sh
./penmods-flutter /userdisk/flutter 800 480 --band=127,127
```

runner 把第 4 个参数起原样透传给 `main(List<String> args)`。应用侧用一个
`MaterialApp.builder` 统一套 `Padding(top: 127, bottom: 127)` + 黑色底即可
（`demo/lib/main.dart` 里的 `Band` 就是这个实现，可以直接抄）。不传就退化为全屏。

启动器（插件管理）应当总是带上这个参数，别让每个插件自己算。

## 两个必须记住的约束

1. **runner 的主循环最多睡一帧。** Wayland 事件是在 `FlutterDesktopViewDispatchEvent()`
   里派发的，`FlutterDesktopEngineProcessMessages()` 返回的等待时间可能很长；照那个值
   `nanosleep` 会把输入事件一直留在队列里，表现是"界面正常、点击全无"，连键盘也收不到。
   当前实现把上限压到 16 ms。
2. **必须给显式宽高。** `kFullscreen`（宽高都传 0）在设备上会先报
   `Could not create a resource context for async texture uploads`，然后 segfault；
   传 `800 480` 正常。

## 调试

```sh
FLUTTER_LOG_LEVELS=TRACE ./penmods-flutter /userdisk/flutter 800 480
```

只有 `build_embedder.sh` 编出来的 .so 才会打 trace（官方 release 没定义
`ENABLE_ELINUX_EMBEDDER_LOG`）。默认级别是 `WARNING`，不设环境变量基本看不到东西。

Dart 侧 `debugPrint` 在 release AOT 下会写到 stdout，排查时可用来确认事件是否到达。

## 设备上的触摸注入

设备的 libwayland 只有旧 API，但这与注入无关；注入坐标要按 `doc/DEVICE_OPERATIONS.md`
的 YDP03X 换算：

```
ux = (dx - 2.5) / 2.5      uy = dy / 2.8235
```

即注入器的 `ui` 坐标空间是 170×320 网格，**不是** 800×480 桌面像素。
