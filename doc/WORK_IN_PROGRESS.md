# 进行中的工作快照（2026-11-09）

> 用途：跨会话交接。只记录“当前状态 + 下一步”，历史见 git log 与各专题文档。

## 设备现状（YDP03X / 2.7.3）

- ADB 正常；重启后首次连接需要 `adb shell auth`，密码 `CherryYoudao`。
- `/userdisk/PenMods/libPenMods.so` 已部署当天构建（含懒加载、shell 配置、`LD_*` 清理）。
- agent 用户：`agent` uid/gid 2000，home `/userdisk`，密码锁定。
- sudo：Alpine 的 sudo 1.9.17（musl）+ `/etc/sudoers` 中 `agent NOPASSWD: ALL`；
  依赖 `/lib/ld-musl-aarch64.so.1`、`/usr/lib/sudo/`。刷机会丢，需要重装。
- muslrun（`/userdisk/.local/bin/_muslrun`）：已优化并提交到设备仓库
  `/userdisk/agent/proj/loadlauncher`（commit `5f77d78`）。
- gdb 15.2 已装进 Alpine rootfs；宿主侧 `/userdisk/.local/bin/gdb` 是包装脚本，
  带 `--data-directory`，通过 `exec -a gdb _muslrun` 分发。
- WiFi：曾出现 SDIO 掉卡（`wlan0` 消失、`/sys/bus/sdio/devices` 为空），
  重启后恢复（192.168.1.8）。根因未定位，存在复发风险。

## 已完成、但尚未提交到主仓库

1. **会话懒加载**
   - `SessionRepository::load()` 只读元数据；新增 `loadMessages(id)`
   - `SessionManager::ensureLoaded()/isLoaded()`；`messages()` 首次访问才解码；
     `switchSession()` 加载目标并释放其它会话
   - facade 的会话列表改用 `messageCount`
   - 实测收益：短会话 429.5 MB vs 353 条大会话 431.2 MB（约 1–2 MB），
     当前数据规模下不显著，价值在扩展性与启动耗时
2. **Shell 工具配置**
   - `ai.shell_tool.program`（默认 `/bin/bash`）
   - `ai.shell_tool.run_as`（`agent` → `sudo -u agent ...`）
   - `ai.shell_tool.source_script`（`/userdisk/PenMods/agent-env.sh`，每条命令前 source）
3. **ShellTool 剥离 `LD_PRELOAD` / `LD_LIBRARY_PATH`**
   - 修复“所有命令退出码 127”的根因：宿主由 `stdbuf` 拉起，glibc 的
     `libstdbuf.so` 被注入 musl 进程（`__fprintf_chk` 缺符号）
4. **token 用量落库**：`sessions.tokens_in/out/reasoning/cache_read/cache_write`

## 测试与构建

- host 全量测试通过（14 个可执行，含 session_*、protocol、chat_engine、shell_tool …）。
- 设备构建：`.toolchain/tmp/.xmake1000/<日期>/zigcc` 会随日期变化；路径失效时
  必须 `xmake f -y -c` 重配，否则报 `cannot runv(...zigcc/c++...)`。

## 待办

- [ ] 提交懒加载 + shell 配置两批改动（主仓库，未 commit）
- [ ] WiFi SDIO 掉卡根因：观察是否复发；必要时加 watchdog/重连脚本
- [ ] gdb 收尾：把 `gdb` 加入 `proj/loadlauncher/install.sh` 的保留名单
      （否则会被替换成软链），并在 `toolchain.md` 记录用法
- [x] QEMU：确定上游/社区无可用方案；用 :P 的 virtualpen（6.6 virt 内核 + 自建 initramfs）
      已在 Linux 上跑通二代并截图；详见 [QEMU.md](QEMU.md)
- [ ] 三代 QEMU：环境已拼到 app 启动（`APP-START` 之后卡在 `isNeedProcessUresourceLost`，
      Weston 无 surface）；initramfs 里已留 `gdb -p $APP ... thread apply all bt` 钩子，
      下一步抓主线程栈定位
- [ ] 内存大头定位（可选）：真机逐页 RSS 采样；已知 Qt 空白基线 52 MB，
      宿主 App ~380 MB，glibc arena 限制无效，消息文本仅 1–2 MB

## 回滚/备份

- 旧 muslrun：`/userdisk/agent-setup-backup/_muslrun.pre-opt-20261106`
- 旧 sudo shim：`/userdisk/agent-setup-backup/sudo.shim`
- `runDictPen`：`/userdisk/agent-setup-backup/runDictPen.pre-arena`（arena 实验已回滚）
- 设备软件包：`/userdisk/PenMods/libPenMods.so.bak-*`、`YoudaoDictPen.stock*`
