# AI 会话层重写：进度页

> 这是活文档。每次有模块落地、测试数变化、设备状态变化，**先改这里**再继续写代码。
> 设计与验收标准见 [`AI_SESSION_MIGRATION.md`](AI_SESSION_MIGRATION.md)；架构事实见 `AI_SESSION_ARCH.md`。
>
> 最后更新：2026-10-28 06:30（Asia/Shanghai）

| 项 | 值 |
|---|---|
| 分支 | `feat/ai-session-v2` |
| 方案 | **B：完全重写，一次性切换**（禁止把新栈桥接进旧 `Backend.cpp`） |
| 总进度 | **约 90%**（切换完成，旧 Backend 已删除；剩余是少量 parity 补验） |
| 线上路径 | 仍是旧 `Backend`；设备已恢复到桥接前的 `.so` |
| host 测试 | **690 checks 全绿**（switch 后复跑） |
| 设备构建 | 通过；`NEEDED` 无 libstdc++/libc++，最高 `GLIBC_2.27` |
| 提交 | 无。用户未要求前不 commit |

---

## 1. 模块状态

| 模块 | 状态 | 文件 | 测试 | 还差什么 |
|---|---|---|---|---|
| `core/` | 完成 | `MessageData.h`、`MessageJson`、`RequestLog` | 73 + 8 + 10 | 无 |
| `session/SessionStore` | 完成 | SQLite 适配层、事件 append/尾部删除、schema 版本闸门 | 56 | zstd/BLOB（P1b，可选） |
| `session/SessionRepository` | 完成 | `MessageData ↔ SessionEvent`、`appendMessages`、`syncTail` | 34 | 无 |
| `session/SessionManager` | 完成 | 内存会话表 + 写穿、active session | 35 | 会话窗口化（P3） |
| `protocol/` | 完成 | `ProtocolAdapter` + chat_completions / responses、`StreamEvent` | 90 | 真实网关回放 fixture |
| `context/` | 完成 | `HistoryTrimmer`、`ContextAssembler`、tool 序列重建 | 17 + 30 | 回放旧会话备份做断言 |
| `model/` | 完成 | `ModelRegistry`、`PromptStore` | 63 | 接到 mod Config 读写（facade 层） |
| `tools/` | 完成 | `ToolBatch`、`ShellTool`（QProcess）、`WebSearchTool` | 56 + 58 + 81 | `VisionProxy`、工具循环在 facade |
| `ChatEngine` | 完成 | 请求生命周期、流式累积、tool_calls、取消、30s 空闲超时 | 79 | 无 |
| `ChatBot` facade | 完成并切换 | 46/31/43，契约脚本核对通过；旧 `Backend.*` 已删除 | — | 无 |
| `ChatBot` facade | 未开始 | — | — | 46 invokable / 31 property / 43 signal |
| 设备 parity | 未开始 | — | — | 26 项清单 |
| 切换 | 未开始 | — | — | 替换 facade、删除旧 `Backend.*` |

---

## 2. 测试

```sh
tests/run.sh              # 472 checks
SANITIZE=1 tests/run.sh   # ASan + UBSan
```

| 测试 | checks | 覆盖 |
|---|---|---|
| `test_request_log` | 73 | 失败日志、脱敏、轮转、限流 |
| `test_history_trim` | 17 | token 估算、整轮丢弃 |
| `test_message_json` | 8 | tool-call 的 `reasoning_content` / `tool_calls` |
| `test_request_sequence` | 10 | 工具序列不被拆开 |
| `test_protocol` | 90 | 两协议请求体、SSE 分片、tool_call 增量、usage、错误、图片 |
| `test_context` | 30 | system prompt、空 assistant、tool 重建、预算裁剪 |
| `test_models` | 63 | 模型/提示词归一化、CRUD、proxy 清理 |
| `test_tools` | 56 | tool_calls 解析、状态机、Shell 策略、UTF-8 截断 |
| `test_session_store` | 56 | schema、CRUD、事件、尾部删除、seq 复用、降级保护 |
| `test_session_repository` | 34 | 事件级追加、尾部重写、往返 |
| `test_session_manager` | 35 | 写穿、切换、重开恢复 |
| `test_shell_tool` | 58 | 审批/拒绝/超时/取消/非零退出 |
| `test_search_tool` | 81 | 配置归一化、请求构造、格式化、重试、取消 |
| `test_chat_engine` | 71 | 流式/非流式、错误、取消、tool_calls 聚合、Responses 工具状态 |

Sanitizer 记录：**472 checks 全量 ASan/UBSan 通过**；随后新增 Shell/Search/Engine 的全量复跑被环境中断两次，尚未补验。
测试基建已改为 make 增量：冷启动 17s、无改动 0.5s、单模块约 4s。

---

## 3. 设备状态（2026-10-28 05:35 核对）

- `/userdisk/PenMods/libPenMods.so` 已从 `libPenMods.before-sessionstore.so` 恢复，sha256 一致
  （`87d7e800…`），进程 5199 加载的是旧版本。
- 桥接期间创建的 `penmods.db` / `-wal` / `-shm` 已删除。
- 启动日志：`ChatBot 初始化完成`、`已加载 1 个会话`、无崩溃。
- 旧会话文件实际在 **`/userdisk/PenModssessions.json`**（旧 `sessionsFilePath()` 少一个 `/`）。
  **不迁移**，原样保留；新栈不读取它。
- 新构建已部署过两次；v2 通过 `/userdisk/PenMods/chatbot_v2` 标记接管 `chatbot`。
  已验证：facade 初始化、`/userdisk/PenMods/penmods.db` 建库、用户消息落库、请求发出。
- **设备网络没有公网出口**：网关可达，`ping 223.5.5.5` 失败；到 API 的 TCP 停在 `SYN_SENT`。
  这就是界面“一直转圈”的原因，不是 facade 死循环。
- 已给 `ChatEngine` 加 30s 空闲超时；带该构建已部署，但尚未在设备上确认超时提示。
- 2026-10-28 05:20 事故：部署启用 v2 标记的构建后设备进入 recovery/shell 认证状态。
  已通过 `adb shell auth` 恢复：删除 `/userdisk/PenMods/chatbot_v2`、把
  `libPenMods.before-sessionstore.so` 恢复到 `libPenMods.so`（哈希 `87d7e800…`），重启后旧实现正常。
- 根因未定论（新 facade 无条件构造是最大风险点）。已改为**一次性试用门禁**：
  `Mod.cpp` 只在 marker/env 存在时构造 `ChatBotV2`，且构造前先删除 marker；
  即使启动崩溃，下一次启动也会自动回到旧实现，不会形成崩溃循环。
- 2026-10-28 05:27 重装完成：当前 `_a` 槽的 `/oem/YoudaoDictPen/output/YoudaoDictPen` 没有 mod 依赖，
  且官方 Loader 注入链（`/userdisk/Loader`、`/usr/bin/try_inject`）完全缺失；官方 pack 服务不可达。
  用 host `patchelf` 给当前二进制加 `NEEDED libPenMods.so` + `RUNPATH /userdisk/PenMods`，
  备份原厂后写回并重启。验证：maps 里 7 段 `/userdisk/PenMods/libPenMods.so`，旧 ChatBot 正常初始化。
  步骤见 `doc/DEVICE_OPERATIONS.md` §3.5。
- 2026-10-28 05:32 门禁构建已部署并验证：
  - 无 marker 启动：只构造旧 `ChatBot`，日志无 `ChatBotV2`；
  - 放 marker 启动：`ChatBotV2 初始化完成, db=/userdisk/PenMods/penmods.db`，marker 被自动删除，无崩溃；
  - AI 页可打开、发消息后用户事件落库（`events` 2 条），断网下 30s 超时结束请求，进程存活，日志无 QML 错误；
  - 2026-10-28 05:37 网络切到 `CU_65Rw` 后完成主链路验证：新会话发消息 →
    真实 API 流式回复 → `assistant-text` 事件落库（431 字节）；会话标题被 QML 自动改成首条消息。
  - 已用数据库验证：新建会话、active 切换、重命名（QML 自动标题）、消息/回复落库。
  - 2026-10-28 05:49 工具链真机跑通：web_search ×2 → 2 条 tool-result → 自动续轮 → 总结落库。
    期间修掉 facade 的一个真 bug：`onFinished` 里 `const bool cancelled = result.cancelled || cancelled;`
    读的是未初始化局部变量，导致工具分发被跳过。
  - 已补：搜索 transport（之前没接，搜索必然失败）、工具批处理 45s 兜底、搜索结束日志。
  - **尚未验证**：Shell 审批 UI、取消按钮、会话切换 UI、模型/搜索设置页。
  - **范围决定**：视觉代理、传统 think 标签、Tavily 先不支持。

---

## 4. 决策记录

| 日期 | 决策 | 原因 |
|---|---|---|
| 10-28 | B：完全重写，一次性切换 | 增量迁移被明确否决（“没让逐步迁移”） |
| 10-28 | 桥接改动全部 revert，旧 `Backend.*` 冻结 | 同上；补丁存 `.tmp/backend-bridge.patch` 仅作参考 |
| 10-28 | **旧会话不迁移** | 用户决定；新库空库起步，旧 `sessions.json` 不读不删 |
| 10-28 | 一条消息 = 一个持久化事件 | 流式增量不落盘，完成/取消时追加一次，写入量可控 |
| 10-28 | 编辑/删除/重生成 = 删除尾部 + 重写 | 单用户小会话；比 shadow 事件简单，DB 不膨胀 |
| 10-28 | Qt 允许，头文件不用 module | Zig + glibc 2.27 编不了 `.cppm`；Qt 5.15 减少转换 |
| 10-28 | SQLite `3.54.0+100` + SQLiteCpp `3.4.0` 静态 | 避免双 SQLite；设备只留一份 |
| 10-28 | schema `PRAGMA user_version` 闸门 | 新版本库拒绝旧程序打开，避免写坏 |
| 10-28 | 视觉代理暂缓 | 用户决定先打通主链路；facade 对已配置代理的情况返回明确错误，不静默降级 |
| 10-28 | 请求加 30s 空闲超时 | 设备断网时旧实现无限转圈；超时后走 errorOccurred + streamEnd |

---

## 5. 参考实现（DSH / opencode）

本机有 `@deepseek-ai/dsh` 源码包和 opencode 的真实数据库（`~/.local/share/opencode/opencode.db`）。
已核对，结论如下。

### 抄了

- **流一定有终止事件**（DSH `dsh-llm`：每次 stream 以 terminal finish 结束）→ `ProtocolAdapter::finish()`
  在缺少 `[DONE]` 时合成 `Done`。
- **provider 适配器独占线格式，调用方只记日志**（DSH `dsh-llm`）→ `ProtocolAdapter` + `RequestLog` 分层。
- **模型可见输入必须能从日志重建**（DSH `dsh-llm` / `dsh-session`）→ 事件 JSON 保存 reasoning、
  tool_calls、toolStates，而不是只存渲染文本。
- **schema 版本 + migration 注册表**（DSH `dsh-session-format`、opencode `migration` 表）→
  `PRAGMA user_version` 闸门 + `migration` 表；下一步把相邻迁移函数化。
- **会话行自带 token/cost 列**（opencode `session`）→ `SessionMeta` 已有同名字段。
- **事件表 `(session_id, seq)` 唯一 + `(session_id, type, seq)` 索引**（opencode `session_message`）→
  已加 `(session_id, kind, seq)` 索引。

### 没抄（记录原因）

- **shadow / replace 事件表面**（DSH `surfaceOp: {op:'replace', startSeq, endSeq}`）：能保留历史、
  支持 undo，但每次编辑多一轮查询与状态折叠；PenMods 单用户、会话短，直接删尾部更省 flash 写入。
  若以后要做“撤销编辑”，再升级到 replace 事件。
- **每会话一个 JSONL 文件 + 派生 SQLite**（DSH persistence）：设备上单文件 SQLite 更省文件系统开销，
  也便于一次事务写。
- **message/part 两张投影表**（opencode）：QML 只需要消息级列表；我们在内存里保留投影，落盘只存事件。
- **FTS5 全文搜索**：设备 RAM/闪存都不适合，且 QML 没有跨会话搜索入口。

---

## 6. 下一步（按顺序）

1. `ChatBot` facade（46/31/43 契约、配置读写、QML 注册）：QProcess、超时、审批/拒绝、输出截断（策略已就绪）。
2. 工具循环 + `VisionProxy`：批处理回填、自动续轮、两阶段视觉、附件落盘。
3. 设备 parity（26 项）、切 `.so`、删除旧 `Backend.*`。
4. 单独一个切换 commit（便于整体 revert）。

## 7. 维护规则

- 每次改完模块：更新 §1 状态、§2 测试数、§3 设备状态（如果动过设备）。
- 测试数必须是 `tests/run.sh` 的真实输出，不能估算。
- 决策只要影响外部行为或文件格式，就进 §4；不要只写在聊天里。
