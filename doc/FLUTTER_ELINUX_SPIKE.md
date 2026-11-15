# 嵌入式 Flutter（flutter-elinux）可行性 spike

状态：**可行性已验证，输入通路待修**。本文记录 2026-11-15 在一台 YDP03X 上实测的过程与结论，
用于后续决策，不代表已经集成进 PenMods。

## 1. 结论先行

| 问题 | 答案 |
|---|---|
| 预编译引擎能在设备上跑吗 | **能**。只需 glibc 2.18 / GLIBCXX 3.4.21，设备是 2.27 / 3.4.22 |
| 需要自己编引擎吗 | **不需要**。省掉了最大的成本（Chromium 工具链 + 数小时构建） |
| 能出画面吗 | **能**。Mali G31 + Wayland，800×480 正常合成 |
| MD3 能用吗 | **能**。Flutter 3.29 自带完整 Material 3，纯黑主题 + 中文正常 |
| 内存多少 | **RSS 67.8 MB / 峰值 68.3 MB**（远低于预估的 80~150 MB） |
| 体积多少 | 整包 **30 MB**：引擎 14.3 + AOT libapp 4.9 + icudtl 10.5 |
| 输入能用吗 | **能**。根因是宿主 runner 主循环睡太久，不是 embedder（见 §6） |
| SDK 状态 | flutter-elinux 停在 Flutter 3.29.3 / Dart 3.7.2，不支持 Impeller，维护接近停滞 |

结论：**技术路完全可行**，渲染、中文、内存、输入四项全部实测通过。

## 2. 为什么考虑 Flutter

起因是 UI 层重写。设备里宿主 app 是闭源 Qt 5.15.2，只有 QtQuick.Controls **1**（无 Controls 2），
所以 MD3 在 Qt5 上没有任何可用实现。Flutter 是唯一能低成本拿到完整 MD3 的路径。

定位（已定）：**不接管宿主 UI**，而是给"插件应用"当运行时 —— 插件 = 一个 Flutter bundle，
宿主只负责 `exec` / 等待退出 / 回收。理由：

- 不碰 Window 管理。Weston 是 desktop-shell + `panel-position=none`，没有任务切换 UI，
  谁做窗口管理谁就要自己解决"怎么回去"。
- 崩溃天然隔离：插件崩 = 一个进程死掉，宿主不受影响（这正好补上插件系统最疼的一处，
  见 §7）。
- 与已有的外置播放器（mpv 作为独立 Wayland 客户端）是同一模式。

## 3. 实测环境

- 设备：YDP03X，rk3326，480×800 面板 + Weston `transform=270` → 桌面 800×480，glibc 2.27，
  libstdc++ 6.0.22（GLIBCXX 到 3.4.22），`/dev/mali0` + `/dev/dri` 存在
- 面板内存：984 MB 物理；宿主 app RSS 465 MB；free 约 38 MB + zram swap 384 MB
- SDK：`~/.local/opt/flutter-elinux`（clone 自 sony/flutter-elinux），Flutter 3.29.3 / Dart 3.7.2
- 引擎产物：GitHub release tag `cf56914b32`（与 SDK 的 engine revision 一致）

## 4. 构建与部署（可复现）

### 4.1 引擎与头文件

```sh
# 引擎 + 后端 embedder（arm64），约 9 MB
curl -LO https://github.com/sony/flutter-embedded-linux/releases/download/cf56914b32/elinux-arm64-release.zip
# 头文件 + cpp wrapper + icudtl.dat，约 4.6 MB
curl -LO https://github.com/sony/flutter-embedded-linux/releases/download/cf56914b32/elinux-common.zip
```

`elinux-arm64-release.zip` 里还带 `linux-x64/gen_snapshot` —— **Dart 的 AOT 交叉编译因此可以在
x86 主机上完成**，不需要在设备上编任何 Dart 代码。

`flutter_elinux.h` 是 C++ 风格（`enum` 不带 tag），直接用 C 编译会报
`must use 'enum' tag`；本地复制一份并把 `view_rotation` / `view_mode` 两个字段改成
`enum FlutterDesktopViewMode view_mode;` 即可，其余不改。

### 4.2 宿主 runner（19 KB，纯 C）

不用官方那套 C++ wrapper + CMake（它需要完整的 arm64 sysroot）。改用 `flutter_elinux.h` 的
C API 写一个极小 runner：组装 `assets_path` / `icu_data_path` / `aot_library_path`
（都是 `wchar_t*`），`FlutterDesktopEngineCreate` → `FlutterDesktopViewControllerCreate`，
然后跑主循环：

```c
while (FlutterDesktopViewDispatchEvent(view)) {
  uint64_t wait_ns = FlutterDesktopEngineProcessMessages(engine);
  if (wait_ns == UINT64_MAX) wait_ns = 16000000ULL;
  nanosleep(...);
}
```

编译：

```sh
zig cc -target aarch64-linux-gnu.2.27 -O2 -I host/include \
  -o penmods-flutter host/main.c libflutter_elinux_wayland.so \
  -Wl,-rpath,'$ORIGIN/lib' -Wl,--allow-shlib-undefined -lpthread -ldl -lm
```

注意：`DispatchEvent()` 内部是 `poll(..., 0)` 非阻塞 + `wl_display_read_events`，事件泵由这个
循环驱动，所以循环必须持续调用它（不能睡太久）。

### 4.3 Dart 侧

```sh
flutter-elinux create --project-name penmods_app --org com.penmods spike
# 替换 lib/main.dart
cd spike
flutter-elinux build elinux --release --target-arch=arm64
```

`build elinux` 会在 CMake 链接阶段失败（用宿主 clang 链接 arm64 引擎 → `file in wrong format`），
但**在失败之前已经产出我们要的东西**：

- `elinux/flutter/ephemeral/libapp.so`（arm64 AOT，4.9 MB）
- `build/elinux/flutter_assets/`（资源，含 tree-shake 后的 Material 图标字体 1.8 KB）

即：官方这条命令被当成"只编 Dart + 资源"的前置步骤使用，runner 用我们自己的。

### 4.4 bundle 布局

```
/userdisk/flutter/
├── penmods-flutter                 # 我们的 runner
├── lib/
│   ├── libapp.so                   # Dart AOT
│   ├── libflutter_elinux_wayland.so
│   └── libflutter_engine.so
└── data/
    ├── icudtl.dat
    └── flutter_assets/...
```

运行：

```sh
cd /userdisk/flutter
XDG_RUNTIME_DIR=/var/run WAYLAND_DISPLAY=wayland-0 \
LD_LIBRARY_PATH=/userdisk/flutter/lib \
./penmods-flutter /userdisk/flutter 800 480
```

- `LD_LIBRARY_PATH` 必须设：embedder 自己没有 RUNPATH，找不到 `libflutter_engine.so`。
- 必须给显式宽高。`kFullscreen`（宽高都传 0）实测会先报
  `Could not create a resource context for async texture uploads` 然后 **segfault**；
  `kNormalscreen` + 800×480 正常。这条要作为启动器的硬约束写死。

## 5. 验证结果

- 截图确认：纯黑底、MD3 AppBar / FilledButton / Switch / ListTile / OutlinedTextField / Chip /
  `AlertDialog` 全部正常，中文（系统 Noto/HYQiHei 经 fontconfig）正常出字
- Dart 侧自报 `APP logical size=800.0x480.0 dpr=1.0`，说明视口与桌面坐标一致
- 进程 RSS 67.8 MB，宿主 465 MB，总量仍在 984 MB 内
- `debugPrint` 在 release AOT 下确实会到 stdout（排查时可用）

## 5.5 内容带（黑边）

笔的 UI 不铺满整块屏：宿主自带界面只占中间一条，实测（800×480，多页对比）

| 页面 | 内容行范围 |
|---|---|
| 主页 | 127 .. 352 |
| 主页（另一页） | 127 .. 352 |
| 设置页 | 131 .. 366 |

即上下各约 127 px 纯黑，内容带高约 226 px 且基本居中。

**不要用缩小窗口来实现**：Weston 的 desktop-shell 不会把 800×227 的窗口居中，实测落在
y≈99，下方直接露出宿主页面。

正确做法：窗口保持全屏 800×480，runner 通过 Dart 入口参数下发内容带：

```sh
./penmods-flutter <bundle> 800 480 --band=127,127
```

应用侧用 `MaterialApp.builder` 套一层 `Padding` + 黑底（见 `tools/flutter-elinux/demo` 里的
`Band`）。不传参数则退化为全屏，向后兼容。

## 6. 输入：曾经的"不通"及其根因

### 6.1 现象

应用能画出 MD3 界面，但任何点击/触摸都没有反应；Dart 侧 `GestureDetector` 收不到事件。

### 6.2 排查过程与排除项

| 检查 | 结论 |
|---|---|
| 注入器本身 | 好的。同一个注入器能让宿主 app 跳转、让 qmlscene 打出 `PROBE press` |
| 坐标换算 | 好的。`doc/DEVICE_OPERATIONS.md` 的 `ux=(dx-2.5)/2.5`、`uy=dy/2.8235` 是对的；用 800×480 桌面像素或 `INJECTOR_PANEL=480x800` 都会点错地方 |
| dpr / 视口 | 好的。Dart 侧自报 `APP logical size=800.0x480.0 dpr=1.0` |
| seat 能力 | 好的。重建 embedder 并打印能力位后确认 `pointer=1 touch=1 keyboard=1` |
| 窗口堆叠/焦点 | 与点击无关。加了窗口装饰、换成 400×300 都一样 |

关键手段：**预编译的 embedder `.so` 没有定义 `ENABLE_ELINUX_EMBEDDER_LOG`，所以
`FLUTTER_LOG_LEVELS=TRACE` 什么都打不出来**。必须自己重建 embedder（配方见 §9，已脚本化为 `tools/flutter-elinux/scripts/build_embedder.sh`），
才能看到 `wl_pointer_listener.*` / `wl_keyboard_listener.*`。

### 6.3 根因

在自己写的 runner 主循环里：

```c
while (FlutterDesktopViewDispatchEvent(view)) {
  uint64_t wait_ns = FlutterDesktopEngineProcessMessages(engine);
  if (wait_ns == UINT64_MAX) wait_ns = 16000000ULL;   // ← 只挡了 UINT64_MAX
  nanosleep(wait_ns);
}
```

Wayland 事件是在 `FlutterDesktopViewDispatchEvent()` 内部派发的（`wl_display_prepare_read`
+ `wl_display_read_events` + `dispatch_pending`）。`ProcessMessages()` 返回的是"距离下一个
引擎任务还有多久"，可能很长；循环一睡，输入事件就一直留在队列里没派发。表现就是
"界面正常、输入全无"，而且连键盘都收不到。

修法一行：把睡眠封顶在一帧。

```c
if (wait_ns == UINT64_MAX || wait_ns > 16000000ULL) wait_ns = 16000000ULL;
```

改完立即出现 `wl_pointer_listener.enter` → `button`、`wl_keyboard_listener.enter`，
应用里的 MD3 按钮计数正常增长、Switch 正常拨动。

**这条必须写进启动器约束**：任何替代 runner 的写法都要保证至少每 16 ms 调一次
`FlutterDesktopViewDispatchEvent()`。

## 7. 与插件系统的关系

这一层解决的是插件系统里"插件崩溃连坐宿主"的问题，纯 QML 插件不必再跟宿主同进程。
但它**不能取代** Hook API 那档：跨进程无法 hook。

配套需要定的（尚未开始）：

- 插件目录约定：`metadata.json` 增加 `"runtime": "flutter"` + bundle 路径，或直接 `entry_exec`
- 生命周期：同时只允许一个 Flutter 应用（内存约束），退出即回收
- 子进程环境：必须清掉 `LD_PRELOAD`（否则插件 app 会被注入 `libPenMods.so`，隔离失效）
- 返回：Weston 无任务切换，需要宿主监听硬件键来 `kill` 子进程，或要求应用自带返回控件
- 输入法：宿主的中文键盘是宿主进程里的 QML 页，Flutter 进程拿不到 —— 需要自带键盘或走 IPC

## 8. 复现清单

spike 的产物流已经从 `/tmp` 搬进仓库，不再是一次性的：

| 路径 | 内容 |
|---|---|
| `tools/flutter-elinux/runner/main.c` | 宿主 runner（含"最多睡一帧"的修复） |
| `tools/flutter-elinux/demo/` | MD3 组件样张（按钮 / 开关 / 输入框 / 列表 / 对话框 / SnackBar） |
| `tools/flutter-elinux/diag/pointerd.c` | 让合成器提前持有指针设备的诊断工具 |
| `tools/flutter-elinux/scripts/` | `setup_sysroot.sh` / `build_embedder.sh` / `build_runner.sh` / `build_app.sh` |
| `tools/flutter-elinux/README.md` | 用法与两条硬约束 |

中间产物落在 `.tmp/flutter-elinux/`（不进 git）。设备侧 `/userdisk/flutter/` 是持久分区上的
demo bundle，`/userdisk/injector`、`/userdisk/pointerd` 是调试工具。

## 9. 重建 embedder（拿 trace 日志 / 换 API 版本）

设备上的 `libwayland-client.so.0` **没有** `wl_proxy_marshal_flags`（那是 wayland ≥1.20 的
API），所以用宿主的 1.26 头文件编出来的 embedder 会直接
`symbol lookup error: undefined symbol: wl_proxy_marshal_flags`。必须用 **wayland 1.16**
的头文件与 scanner，让生成的协议代码走 `wl_proxy_marshal*` 老 API。

一次性的准备工作：

```sh
# 1) wayland 1.16 源码 + scanner（scanner 需要 wayland-util.c 与 expat）
curl -LO https://gitlab.freedesktop.org/wayland/wayland/-/archive/1.16.0/wayland-1.16.0.tar.gz
tar xzf wayland-1.16.0.tar.gz && cd wayland-1.16.0 && echo '' > src/config.h
gcc -O2 -I src -o wayland-scanner-1.16 src/scanner.c src/wayland-util.c -lexpat

# 2) 头文件集合：wayland 1.16 的 client/core/util + 用 1.16 scanner 生成的
#    wayland-client-protocol.h，再加宿主提供的 EGL/GLES2/KHR/xkbcommon/linux/input.h
#    （这些头是架构无关的；但绝不能把 /usr/include 整个加进搜索路径，
#     否则宿主的 glibc 头会压过 zig 的 2.27 头，出现 __float128 之类的报错）

# 3) 从设备拉运行库用于链接（soname 与设备一致）
adb pull /usr/lib/libwayland-client.so.0  ...  (cursor/egl/xkbcommon/EGL/GLESv2 同理)

# 4) pkg-config 垫片：把 .pc 里的 Libs 清空、Cflags 指向上面的头目录，
#    避免链接到宿主 x86 库
```

配置与构建（`ENABLE_ELINUX_EMBEDDER_LOG` 就是 trace 开关）：

```sh
cmake -S . -B build-arm64 -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \        # C/CXX = zig cc/c++ -target aarch64-linux-gnu.2.27
  -DBACKEND_TYPE=WAYLAND -DBUILD_ELINUX_SO=ON \
  -DENABLE_ELINUX_EMBEDDER_LOG=ON -DCMAKE_BUILD_TYPE=Release
# ninja 里写死了 /usr/bin/wayland-scanner，改成 1.16 那个，然后删掉已生成的 *-protocol.c/h 重编
PKG_CONFIG_LIBDIR=<垫片目录> cmake --build build-arm64
```

产出的 `libflutter_elinux_wayland.so` 约 16 MB（静态链入 libc++），替换 bundle 里的同名文件即可。

调试时：

```sh
FLUTTER_LOG_LEVELS=TRACE ./penmods-flutter /userdisk/flutter 800 480
```

注意 `logger.cc` 默认级别是 `WARNING`，不设这个环境变量基本看不到任何 embedder 日志。
