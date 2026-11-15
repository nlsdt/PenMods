# compat：上游产物上的两处补丁

这里的文件是**项目的一部分**，不是脚本里的临时 sed。`setup_sysroot.sh` 会把它们应用到
下载下来的上游产物上；每次改动都应当能在这里 review 到。

## 1. `flutter_elinux-c.patch`

上游 `flutter_elinux.h` 的结构体字段用的是 C++ 写法（枚举不带 `enum` tag）：

```c
FlutterDesktopViewMode view_mode;      // C++ 合法，C 非法
```

我们的 runner 是**纯 C**（刻意不引入 C++ ABI，见 README），所以必须补上 tag：

```c
enum FlutterDesktopViewMode view_mode;
```

影响面只有 `FlutterDesktopViewProperties` 的两个字段（`view_rotation` / `view_mode`）。
应用方式：

```sh
patch -p1 -d "$WORK_INCLUDE" < compat/flutter_elinux-c.patch
```

升级引擎产物后如果这个 patch 打不上，说明上游结构体变了，需要重新 gen 一次——
脚本会直接失败而不是静默跳过。

## 2. `wayland-version.h`

wayland 1.16 的 `src/` 不含 `wayland-version.h`（上游由 meson 生成），而
`wayland-client-core.h` 会 `#include "wayland-version.h"`。这里放一份固定 1.16.0 的版本头，
避免去借宿主 1.26 的那份（版本号会影响 `#if WAYLAND_VERSION_*` 分支）。

## 为什么需要 wayland 1.16 而不是宿主版本

设备上的 `libwayland-client.so.0` **没有** `wl_proxy_marshal_flags`（wayland ≥ 1.20 引入）。
用宿主 1.26 的头 + scanner 生成的协议代码会调用它，运行期直接：

```
symbol lookup error: libflutter_elinux_wayland.so: undefined symbol: wl_proxy_marshal_flags
```

所以 `setup_sysroot.sh` 自己编一份 1.16 的 `wayland-scanner`，并用它重新生成协议代码。
