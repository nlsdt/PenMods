# AI 会话后端重写：迁移映射与验收清单

> 对应 `doc/AI_SESSION_ARCH.md` 的落地版。架构定稿在那边，这里只回答三个问题：
> **拆成哪些模块、每个模块负责什么、什么条件下才允许删掉 `Backend.cpp`。**
> 当前进度、测试数、设备状态和决策记录在 [`AI_SESSION_PROGRESS.md`](AI_SESSION_PROGRESS.md)，那页每次动手都要更新。

| 项 | 值 |
|---|---|
| 方案 | **B：完全重写，整体切换**（2026-10-28 确认；ARCH §2.2「不整体重写 `Backend.cpp`」已被本决定取代） |
| 分支 | `feat/ai-session-v2` |
| 当前状态 | **B 已切换完成**（2026-10-28）：旧 `Backend.*` 已删除，新栈：`MessageData` / `HistoryTrimmer` / `RequestLog` / `SessionStore` / `SessionRepository` / `SessionManager`（事件级写入）、`ProtocolAdapter`（两种协议）、`ContextAssembler`、`ModelRegistry`/`PromptStore`、`ToolRuntime`/`ShellTool`/`WebSearchTool`、`ChatEngine` + **682 项 host 测试**；旧 `Backend.cpp` 已 **revert 到 HEAD 并冻结**，未接任何新栈代码 |
| 旧实现 | `src/chatbot/Backend.cpp`（4671 行 / 128 方法），**冻结**，不再加功能，也不做桥接；parity 后整体删除 |
| QML | 本轮不动，`ChatBot` 的 46 invokable / 31 property / 43 signal 作为契约保留 |
| 数据 | **旧会话不迁移**（用户决定）。新库空库起步；旧 `sessions.json` 原样保留、不读不删 |

> **决策记录（2026-10-28）**：确认走 B。`AI_SESSION_ARCH.md` §2.2 的“不整体重写 `Backend.cpp`”作废；
> 该文档的 DDL、事件模型、协议事实仍然有效。
> 旧 `Backend.cpp` 在 parity 全绿前继续是线上路径，但 **不再修改**。曾尝试把 `SessionStore` 桥接进旧
> `Backend.cpp`，被明确否决（“没让逐步迁移”）；改动已保存到 `.tmp/backend-bridge.patch` 并从源码 revert，
> 设备也已恢复桥接前的 `.so`、删掉了桥接期间创建的 `penmods.db*`。之后所有功能只写进新栈。

---

## 1. 原则

1. **终点是 `Backend.cpp` 消失**，不是把它拆小后继续留着。ARCH §2.2 已被 B 取代。
2. **facade 只做翻译**：`ChatBot` 只负责 QML 契约、信号转发、依赖装配；不写协议、不写 SQL、不写装配算法。
3. **核心模块不碰宿主**：不 include `Base.h` / `Hook.h` / `Event.h` / `mod/Config.h` / `mod/Mod.h` / `Utils.h`，不调 `showToast()`，不依赖单例。依赖通过构造函数注入。
4. **宿主可测**：纯逻辑模块能在 x86_64 上用 host Qt 跑；设备只验证 QML、宿主注入、真实网络与性能。
5. **不做兼容层**：新栈不迁就旧方法的签名；facade 负责把旧签名翻译成新接口。
6. **先有验收再切换**：parity checklist 全绿之前，旧 `Backend.cpp` 仍是线上路径。
7. **旧代码只留桥接**：P0.2 之后的任何改动都进新栈；旧文件只允许修致命崩溃。

---

## 2. 目标目录

```text
src/chatbot/
├── ChatBot.{h,cpp}              # QML facade，唯一保留的“旧名字”
├── core/
│   ├── MessageData.h            # 消息结构（从 Backend.h 拆出，host 可测）
│   └── RequestLog.{h,cpp}       # 失败请求日志（P0.1，已落地）
├── session/
│   ├── SessionStore.{h,cpp}     # SQLite + WAL + zstd，事件流/投影
│   ├── SessionRepository.{h,cpp} # MessageData ↔ SessionEvent，QtCore 适配层
│   └── SessionWindow.{h,cpp}    # 懒加载窗口（P3 用）
├── context/
│   ├── HistoryTrimmer.{h,cpp}   # 整轮丢弃 + token 估算（已落地，待接 ContextAssembler）
│   └── ContextAssembler.{h,cpp} # token 预算、reasoning 随轮
├── protocol/
│   ├── ProtocolAdapter.{h,cpp}  # 接口 + 工厂
│   ├── ChatCompletionsAdapter.{h,cpp}
│   ├── ResponsesAdapter.{h,cpp}
│   └── StreamEvent.h            # 统一流事件（text/reasoning/tool/usage/error）
├── tools/
│   ├── ToolRuntime.{h,cpp}      # 工具分发、批处理、状态机
│   ├── WebSearchTool.{h,cpp}
│   ├── ShellTool.{h,cpp}
│   └── VisionProxy.{h,cpp}
├── model/
│   ├── ModelRegistry.{h,cpp}    # /models 拉取、缓存、capabilities
│   └── PromptStore.{h,cpp}      # 提示词 CRUD
├── AttachmentManager.{h,cpp}    # 已有，保留
└── MarkdownParser.{h,cpp}       # 已有，保留
```

`xmake.lua` 用 `add_files('src/**.cpp')`，新增文件自动进设备构建；测试工程单独编译，不依赖设备 PCH。

---

## 3. 模块契约

### 3.0 `MessageData` / `HistoryTrimmer`

- **`MessageData`**：消息结构从 `Backend.h` 拆到 `core/MessageData.h`，只依赖 QtCore；旧 `Backend.h` 也改用它，保证新旧栈只有一份定义。
- **`HistoryTrimmer`**（已落地，host 测试覆盖）：
  - `estimateTokens()`：CJK / 1.5 + 其他 / 4 的粗略估算，只用于预算量级。
  - `trimHistoryToBudget()`：超预算时从最旧的**整轮**开始丢；一个 turn = 一条 user 及其后的 assistant / tool，保证 `tool_calls`、tool 结果、reasoning 不被拆开。
  - `MAX_HISTORY_SIZE = 100` 和 16 处 `removeFirst()` 已删除；改为请求组装时 `trimHistoryToBudget()` 整轮裁剪。
- **请求路径修复**：`core/MessageJson.cpp` 的 `messageToRequestJson()` 对带 `tool_calls` 的 assistant 消息回传
  `reasoning_content`；`ContextAssembler`（待实现）先按模型 context window 整轮裁剪，再序列化。
  这些是 **新栈** 的行为；旧 `Backend.cpp` 未接，线上仍是旧逻辑（`MAX_HISTORY_SIZE` / `removeFirst`）。

### 3.1 `RequestLog`（组件已完成；尚未接入任何 facade）

- **职责**：把失败请求写进 `<模块目录>/ai-errors.log`，一行一条 key=value；超过 256 KB 轮转到 `.1`。
  真实路径是 `/userdisk/PenMods/ai-errors.log`（由 `getModuleFileInfo().absolutePath()` 决定）；
  `/userdata/PenMods` 是 10 月 5 日留下的空壳，不要用。
- **脱敏**：`sk-[A-Za-z0-9_-]{8,}` 与 `Bearer\s+\S+` 替换成 `***`；body 取前 200 字，按 UTF-16 边界截断，不切代理对。
- **限流**：同 `session + status` 每分钟最多 30 条，防止连发 400 把 256 KB 转没。
- **输入**：status、errorText、响应体、session/model/protocol、`RequestSummary`。
- **输出**：写文件成功/失败；失败原因回传调用方，由 facade 打 applog。
- **依赖**：QtCore only。宿主可直接测。
- **不负责**：Toast 文案、会话记录、请求体构造。
- **接线状态**：P0.2 曾接进旧 `Backend.cpp`，随桥接一起 revert；等新 facade 落地后接在协议层。
- 会话里是否再写一条可见错误消息：**已决定不加**（见 §8），只写日志 + Toast。

### 3.2 `SessionStore`（P1）

- **职责**：`penmods.db` 的唯一读写入口；事件追加、按 turn 查询、会话聚合列、懒加载窗口。
- **输入**：`SessionEvent`（turn_id / kind / data / truncated / orig_bytes）。
- **输出**：`std::vector<SessionEvent>`、`SessionMeta`、窗口查询；错误用 `std::expected<T, Error>`。
- **依赖**：静态 SQLite `3.54.0+100`、SQLiteCpp `3.4.0`（RAII/事务）；P1a 先不上 zstd，`events.data` 先存 JSON 文本。
- **错误边界（务实决定 A）**：`SessionStore` 是唯一允许 `try/catch` 的 adapter 层；在这里把 `SQLite::Exception` 转成 `Error`，上层只看到 `expected`，不再出现 `try/catch`。
- **不负责**：token 预算、协议拼装、UI 排序、异常向上传播。

> **P1a 状态（2026-10-28，桥接 revert 后）**：
> - `session/SessionStore.{h,cpp}`：SQLite 适配层（std + SQLiteCpp）；`appendEvents` / `deleteEventsFrom` /
>   `loadEvents` / `loadTurns` / `lastUserTurnId` / `app_state`；schema 用 `PRAGMA user_version` 做降级保护。
> - `session/SessionRepository.{h,cpp}`：`MessageData ↔ SessionEvent`（QtCore 适配层）；公开
>   `appendMessages()` 与 `syncTail(sessionId, messages, keepCount)`，**没有** `saveAll()` 快照写。
> - `session/SessionManager.{h,cpp}`：内存会话表 + 写穿策略；先持久化、成功后才更新内存，
>   所以 RAM 与磁盘不会分叉。旧 `m_sessions` + `saveSessions()` 的职责由它接管。
> - 策略：一条消息 = 一个事件（`data` 是该消息的完整 JSON，含 toolStates/reasoning/tool_calls）；
>   编辑/删除/重生成只重写受影响尾部（`DELETE ... seq >= cutoff` + 重新追加），不整份重写。
>   流式增量不落盘，消息完成/取消时追加一次。
> - host 682 checks（`session_store` 56 / `session_repository` 34 / `session_manager` 35 /
>   `protocol` 90 / `context` 30 / `models` 63 / `tools` 56 / `shell_tool` 58 / `search_tool` 81 /
>   `chat_engine` 71，其余 108）；设备
>   `xmake build PenMods` 通过，`NEEDED` 无 libstdc++/libc++，最高 `GLIBC_2.27`。
> - **设备未部署**：桥接版已回滚，旧 `.so` 上没有任何 `penmods.db` 读写。
> - 待办：真实 `message_count` 投影、`SessionWindow` 懒加载。
> - **不做**：legacy `sessions.json` 导入（用户决定；相关代码路径已删除，包括 `replaceEvents`）。

### 3.3 `ContextAssembler`（P2）

- **职责**：按 seq 倒序取候选事件 → 按 turn 分组 → token 预算内整轮保留/整轮丢弃（复用 `HistoryTrimmer`）→ 带 tools 时附 reasoning 原文。
- **输入**：`SessionStore` 窗口、`ModelRegistry` 的 context_window/max_output、发送上限配置。
- **输出**：`RequestMessages`（role/content/tool_calls/reasoning_content）。
- **依赖**：`SessionStore`、`ModelRegistry`、`HistoryTrimmer`。
- **不负责**：HTTP、流解析、UI。

### 3.4 `ProtocolAdapter`（P2）

- **职责**：把 `RequestMessages` 变成请求体；把 SSE/JSON 响应变成统一的 `StreamEvent`；usage 记账。
- **实现**：`ChatCompletionsAdapter`、`ResponsesAdapter`，由 `ProtocolAdapter::create(protocol)` 选择。
- **输入**：`RequestMessages`、模型参数、tools 定义。
- **输出**：`QByteArray` 请求体；`StreamEvent` 序列。
- **依赖**：QtCore/JSON。不依赖 `SessionStore` / QML。
- **不负责**：重试、UI 状态、工具执行。

### 3.5 `ToolRuntime`（P2–P3）

- **职责**：解析 tool_calls、批处理、执行 search/shell/vision、回填 tool result、维护 tool 状态。
- **输入**：`ToolCall`、工具配置、审批回调。
- **输出**：tool result / 状态事件。
- **依赖**：QtNetwork（搜索）、QProcess（shell）；宿主测试用 mock。
- **不负责**：协议序列化、会话存储。

### 3.6 `ModelRegistry` / `PromptStore`（P1/P4）

- **职责**：`/models` 拉取与缓存（TTL 24h）、capabilities、effort 档位；提示词 CRUD。
- **依赖**：QtNetwork、JSON 文件；不依赖 QML。
- **不负责**：UI 下拉项渲染。

### 3.7 `ChatBot`（facade）

- **职责**：QML 契约（见附录 A）、模块装配、信号翻译、配置读写入口。
- **允许**：`QQuickView` / `Event` / `Config` / `showToast` / `getModuleFileInfo`。
- **禁止**：SQL、HTTP 细节、token 预算、tool 执行。
- **目标**：≤ 800 行，只做转发与状态映射。

---

## 4. 方法映射（128 个旧方法 → 模块）

| 旧方法组 | 新归属 | 备注 |
|---|---|---|
| `initSessions` / `saveSessions` / `sessionsFilePath` / `ensureCurrentSession` | `SessionStore` + facade | JSON 路径删除；新库空库起步，不导入旧 `sessions.json` |
| `getSessions` / `switchSession` / `createSession` / `deleteSession` / `renameSession` / `getSessionMessages` | `SessionStore` + facade | 返回结构保持 QML 兼容 |
| `clearHistory` / `saveMessages` / `currentMessages` | `SessionStore` + facade | 不再整份重写 |
| `sendMessage` / `sendMessageWithMedia` / `finishMediaMessage` | facade + `ContextAssembler` | 附件先落盘 |
| `editMessage` / `editMessageWithMedia` / `truncateHistory` / `deleteMessage` / `regenerateMessage` | `SessionStore` + facade | 事件级操作，不 resize vector |
| `buildApiMessages` / `buildApiMessagesFromHistory` / `messageToJson` / `messagesToResponsesInput` | `ContextAssembler` + `ProtocolAdapter` | 删 16 处 `removeFirst()` |
| `makeApiRequest` / `handleNetworkReply` / `finishStream` / 流缓冲 | `ProtocolAdapter` + facade | 统一 `StreamEvent` |
| `recordApiUsage` / `getApiCacheStats` / `resetApiCacheStats` | `ProtocolAdapter` + facade | usage 归协议层 |
| `prepareTool` / `updateTool` / `publishTool` / `finishOutstandingTools` / `updateServerTool` | `ToolRuntime` | 工具状态机 |
| `dispatchToolCalls` / `submitToolResult` / `submitToolResultBatched` / `tryFlushToolBatch` / `resolvePendingToolCalls` | `ToolRuntime` | 批处理 |
| `initShellTool` / `isCommandBlocked` / `executeShellCommand` / `approve/denyShellCommand` / `cleanupShellExec` / `abortPendingShellExecs` / `truncateOutput` / `get/setShellToolConfig` | `ShellTool` + facade | QProcess |
| `initSearch` / `executeWebSearch` / `executeTavilySearch` / `executeDeepSeekSearch` / `requestDeepSeekSearch` / `formatSearchResults` / `effectiveSearchKey` / `searchConfigured` / `searchToolAvailable` / `saveSearchConfig` | `WebSearchTool` | 兼容 tavily 旧接口 |
| `callVisionProxy` / `persistUserImages` / `persistGeneratedImages` / `attachmentVariants` | `VisionProxy` + `AttachmentManager` | 异步两阶段，禁止嵌套事件循环 |
| `initModels` / `applyModelConfig` / `saveModels` / `add/remove/setActive/getActive/loadModelsFile` | `ModelRegistry` + facade | `/models` 缓存 |
| `initPrompts` / `savePrompts` / `add/remove/setActive/getActive` | `PromptStore` + facade | |
| `markdownToHtml` / `parseMarkdownAsync` / `cancelMarkdownParse` | `MarkdownParser`（已有） | 保留 |
| `initMathRender` / `get/setMathRenderConfig` | facade | 纯配置 |
| 所有 getter/setter / Q_PROPERTY / signal | facade | 契约不变 |

> 映射的验收方式：新 facade 必须覆盖附录 A 的全部签名；旧 `Backend.h` 删除前用脚本逐行比对。

---

## 5. Parity Checklist

每一项都要有 host 测试（H）或设备测试（D），并在切换前打勾。

| ID | 能力 | 验证 | 状态 |
|---|---|---|---|
| F01 | 纯文本发送 / 流式显示 | H + D | ☐ |
| F02 | reasoning 显示、持久化、带 tools 时回传 | H + D | ☐ |
| F03 | tool_calls 拼接 / 批处理 / 结果回填 | H + D | ☐ |
| F04 | shell 工具审批 / 拒绝 / 超时 | H + D | ☐ |
| F05 | vision 代理两阶段流程 | H + D | ☐ |
| F06 | 图片生成与附件落盘 | D | ☐ |
| F07 | 图片 / 音频 / 文件附件 | H + D | ☐ |
| F08 | 会话 CRUD / 切换 / 重命名 | H + D | ☐ |
| F09 | 编辑 / 重新生成 / 截断 / 删除消息 | H + D | ☐ |
| F10 | 模型 CRUD / 激活 / capabilities | H + D | ☐ |
| F11 | 提示词 CRUD / 激活 | H + D | ☐ |
| F12 | 搜索配置 / tavily 旧接口兼容 | H + D | ☐ |
| F13 | 数学公式渲染配置 | H + D | ☐ |
| F14 | Markdown 同步 / 异步解析 | H + D | ☐ |
| F15 | 取消 / 中断 / 错误恢复 | H + D | ☐ |
| F16 | Responses 协议 | H + D | ☐ |
| F17 | Chat Completions 协议 | H + D | ☐ |
| F18 | 长上下文：预算 / 整轮丢弃 / reasoning 随轮 | H | ☐ |
| F19 | 400 文案 + `ai-errors.log` + 请求摘要（P0.2） | H + D | ☐ |
| F20 | API cache 统计 | H + D | ☐ |
| F21 | 代理视觉设置 | H + D | ☐ |
| F22 | 气泡渲染模式 | D | ☐ |
| F23 | 会话持久化（新 SQLite，不迁旧数据） | H + D | ☐ |
| F24 | QML signal 兼容（43 个） | D | ☐ |
| F25 | 启动 / 退出 / 无崩溃 | D | ☐ |
| F26 | Q_PROPERTY 代理（31 个属性迁到新数据源） | H + D | ☐ |

> **F26 单独估时**：31 个 `Q_PROPERTY` 里，`messages` / `toolStates` / `currentSessionId` / `apiCacheStats` / 各 `cap*` 以前是旧成员变量直接 READ；新数据在 `SessionStore` / 协议层。
> facade 需要缓存投影并在数据变化时发 notify，不是“一行转发”。估 2–3 天，别等实现时才发现。

---

## 6. Host 测试

### 6.1 布局

```text
tests/
├── test_main.h              # CHECK / 计数器
├── test_request_log.cpp     # P0.1
├── test_protocol.cpp        # 协议层
├── test_context.cpp         # 上下文装配
├── test_models.cpp          # 模型/提示词
├── test_tools.cpp           # 工具状态机
├── test_session_*.cpp       # 存储/适配/写穿
├── fake_server.py           # 返回 400 / SSE 的本地假服务
└── run.sh                   # 用 host Qt 编核心模块并跑测试
```

### 6.2 运行

```sh
tests/run.sh
```

- 输出目录：`build/tests/`（已被 `build/*` 忽略）；
- `SessionStore` 测试需要 SQLiteCpp 3.4.0 源码（默认 `.tmp/SQLiteCpp`，未 vendored；CI 尚未接，待清债）；
- 编译器：宿主 `g++`（C++23，`std::expected`），`pkg-config Qt5Core`；
- 不用 ccache：只读沙箱里 ccache 建不了临时文件，测试编译本来也只要一两秒；
- 输出目录：`build/tests/`（已被 `build/*` 忽略）；
- 不链接 Dobby / SymDB / QML / 宿主二进制；
- 核心模块必须能单独编译，不能依赖 `Base.h`。

### 6.3 测试类型

| 类型 | 做法 |
|---|---|
| 单元 | `RequestLog`、protocol 请求体、context 装配、store CRUD |
| 回放 | 用 `.device-probe/backup/PenModssessions-20261027.json` 跑装配，断言不产生“tool_calls 与结果被拆开”的序列 |
| 集成 | `fake_server.py` 返回 400 / SSE，走完整 `ProtocolAdapter` + `RequestLog` |
| 黄金文件 | 固定输入 → 固定请求体 JSON / 固定日志行，diff 失败即回归 |

### 6.4 设备上仍需验证

- QML 绑定与 43 个 signal 的时序；
- 宿主注入链（Dobby / qrc / SymDB）；
- 真实网络、TLS、超时、性能与 RSS；
- `/userdisk/PenMods/ai-errors.log` 的实际写入与轮转。

### 6.5 fake server（P0.2 验收）

```sh
# 返回 400，body 里带错误信息
python3 tests/fake_server.py --port 18080 --status 400 \
    --body '{"error":{"message":"Invalid tool_calls sequence"}}'

# 本机：把 baseUrl 指到 http://127.0.0.1:18080/v1/chat/completions
# 设备：若 adbd 支持，adb reverse tcp:18080 tcp:18080，再指到 127.0.0.1
```

验收链：请求失败 → `ai-errors.log` 出现 `status=400` 与 `body=` → applog 有摘要与错误行 → 界面有 Toast。
`fake_server.py` 只用于开发机，不打包进设备。

---

## 7. 切换与回滚（仅当 B 确认后执行）

1. 旧 `Backend.cpp` 冻结，只修致命问题；新模块在 `src/chatbot/*` 并行开发。
2. 每个模块合入前：host 测试通过；设备回归只在新栈接进 facade 后做（冻结期间旧 `.so` 保持原样）。
3. parity checklist 全绿后，替换 `ChatBot` 实现（facade 签名不变），一次性删除 `Backend.cpp`。
4. 设备保留上一版 `libPenMods.known_good.so`；切换失败整体回滚。
5. 切换 commit 必须单独一个，便于 revert。

---

## 8. 开放问题

- **会话错误消息**：会话此前决定“不写可见错误记录，只写 `ai-errors.log`”；审查建议 400 时往会话写一条 error 消息。两者冲突，待用户确认；P0.2 暂按会话决定实现（只日志 + Toast）。
- **旧代码桥接**：已否决并 revert。`Backend.cpp` 保持 HEAD 原样（含 `MAX_HISTORY_SIZE` 与 16 处 `removeFirst`），
  新栈不向它注入任何代码；切换时整体替换 facade，再删掉旧文件。
- Responses 的 tools 格式（文档 §12）与 `injectToolDefinitions()` 的两套形态。
- ~~设备静态 SQLite 3.45+ 与 zstd 的链接方式~~：已定 SQLite `3.54.0+100` + SQLiteCpp `3.4.0`，静态链接；
  zstd 留到 P1b。host 测试用系统 `sqlite3` + SQLiteCpp 源码。
- 会话窗口化（P3）是否需要在 facade 新增分页接口；若需要，属于 QML 契约变更，单独评审。
- 旧 `sessions.json` 的真实路径是 `/userdisk/PenModssessions.json`（`sessionsFilePath()` 少了一个 `/`）。
  **已决定不迁移**：新栈不读、不删这个文件；用户要清理由用户自己处理。
- `mathjax-server` 路径与启动时机保持不变。

---

## 附录 A：QML 契约（当前 `Backend.h`）

### A.1 Q_INVOKABLE（46）

```text
sendMessage / sendMessageWithMedia / isAvailable / reloadConfig / sanitizeConfig / clearHistory /
saveMessages / markdownToHtml / parseMarkdownAsync / cancelMarkdownParse / truncateHistory /
editMessage / editMessageWithMedia / deleteMessage / regenerateMessage / cancelRequest /
resetApiCacheStats / submitToolResult / approveShellCommand / denyShellCommand /
getShellToolConfig / setShellToolConfig / getSessions / getCurrentSessionId / switchSession /
createSession / deleteSession / renameSession / getSessionMessages / getModels / addModel /
removeModel / setActiveModel / getActiveModel / loadModelsFile / getPrompts / addPrompt /
removePrompt / setActivePrompt / getActivePrompt / getSearchConfig / setSearchConfig /
getTavilyConfig / setTavilyConfig / getMathRenderConfig / setMathRenderConfig
```

### A.2 Q_PROPERTY（31）

```text
apiKey / apiEndpoint / model / apiProtocol / temperature / defaultPrompt / isStreaming /
isAvailable / messages / responseMessageId / toolStates / currentSessionId / apiCacheStats /
capText / capVision / capAudio / capToolCall / capReasoning / capImageGeneration /
proxyVisionModelId / proxyVisionPrompt / searchProvider / searchEnabled / searchConfigured /
searchCount / tavilyEnabled / tavilyConfigured / shellToolEnabled / mathRenderEnabled /
mathServerPath / bubbleRenderMode
```

### A.3 Signal（43）

```text
messageReceived / streamStart / streamChunk / reasoningChunk / markdownParsed / streamEnd /
errorOccurred / requestCancelled / toolCallReceived / toolStateChanged / toolStatesChanged /
imageAttachmentsReceived / toolCallProgress / apiKeyChanged / apiEndpointChanged / modelChanged /
apiProtocolChanged / temperatureChanged / defaultPromptChanged / isStreamingChanged /
messagesChanged / apiCacheStatsChanged / modelsChanged / promptsChanged / sessionsChanged /
sessionSwitched / activeModelCapabilitiesChanged / proxyVisionSettingsChanged /
proxyVisionStarted / proxyVisionCompleted / searchConfigChanged / webSearchStarted /
webSearchFinished / tavilyConfigChanged / tavilySearchStarted / tavilySearchFinished /
shellToolConfigChanged / shellCommandPending / shellCommandStarted / shellCommandFinished /
toolBatchFlushed / mathRenderConfigChanged / bubbleRenderModeChanged
```

> 完整签名以 `src/chatbot/Backend.h` 为准；删除旧头文件前用脚本比对，缺一不可。
