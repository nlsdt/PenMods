# Host tests

本目录是本机（x86_64）测试工程，**不参与设备构建**。它直接编译 `src/chatbot/` 下不依赖宿主注入链的核心模块，用 x86_64 Qt5 跑。

## 前置

- 宿主 `g++`（C++23，`std::expected`）
- host Qt5Core 开发包：`pkg-config --exists Qt5Core`
- SQLiteCpp 3.4.0 源码（默认 `.tmp/SQLiteCpp`，未 vendored）：
  ```sh
  git clone --depth 1 --branch 3.4.0 https://github.com/SRombauts/SQLiteCpp .tmp/SQLiteCpp
  ```

测试编译**不用 ccache**：增量 make 已经足够快，ccache 在只读沙箱里还会建不了临时文件。

## 运行

编译交给 `tests/Makefile`：模块对象只编一次、增量重编、`-j` 并行；SQLiteCpp 只编一个静态库。
实测冷启动约 17s，无改动 0.5s，改一个模块约 4s。

```sh
tests/run.sh                          # 全部
tests/run.sh test_protocol            # 只跑指定测试（不动其他目标）
SANITIZE=1 tests/run.sh               # ASan/UBSan（build/tests/san，独立对象目录）
JOBS=4 tests/run.sh                   # 限制并行度
```

只跑一个测试时优先用这种写法，不要再全量编译。

产物写在 `build/tests/`（已被 `build/*` 忽略）。当前包含：

| 测试 | 覆盖 |
|---|---|
| `test_request_log` | 行格式、200 字截断、换行压平、UTF-8 代理对安全、`sk-…` / `Bearer …` 脱敏、256 KB 轮转、写失败、限流、目录创建 |
| `test_history_trim` | token 估算、整轮丢弃、工具调用/reasoning 不被拆开 |
| `test_message_json` | assistant tool-call 的 `reasoning_content` / `tool_calls` 序列化 |
| `test_request_sequence` | 两轮历史 + tool_calls + tool result 的整轮裁剪，不拆开工具序列 |
| `test_protocol` | chat_completions / responses 请求体、SSE 分片缓冲、tool_call 增量与 index、usage、[DONE]、错误、非流式解析、Responses 服务器工具状态 |
| `test_context` | system prompt、空 assistant 丢弃、tool_calls/tool result 重建、整轮预算裁剪、最后整轮保留、多模态 user |
| `test_session_store` | SQLite schema、会话 CRUD、事件追加、按 turn 读取、尾部删除与 seq 复用、`lastUserTurnId`、schema 降级保护、错误路径 |
| `test_session_repository` | `MessageData ↔ SessionEvent`、reasoning/toolCalls/toolStates 往返、事件级追加、尾部重写/截断 |
| `test_session_manager` | 内存会话表 + 写穿：创建/切换/重命名/删除、追加、编辑尾部、重开数据库恢复 |
| `test_models` | 模型/提示词归一化、必填校验、能力位、proxy 清理、active 回退 |
| `test_tools` | tool_calls 解析去重、ToolBatch 状态机/批处理/取消、Shell 策略与 UTF-8 截断 |

## fake server（协议层验收用）

```sh
python3 tests/fake_server.py --port 18080 --status 400 \
    --body '{"error":{"message":"Invalid tool_calls sequence"}}'
python3 tests/fake_server.py --port 18080 --sse
```

只打印方法/路径/字节数，不打印请求体与 Authorization。

## 规则

核心模块（`src/chatbot/core/`、`session/`、`context/`、`protocol/`）必须：

- 只依赖 QtCore / 标准库 / JSON / SQLiteCpp（仅 `SessionStore` 适配层），不 include `Base.h`、`Hook.h`、`Event.h`、`mod/Config.h`、`mod/Mod.h`、`Utils.h`；
- 不调用 `showToast()`，不依赖单例；
- 路径、配置、日志目标都通过构造函数注入。

这样 `tests/run.sh` 才能在没有 Dobby / QML / 宿主二进制的机器上编译并运行。

## 后续

- `test_protocol`：请求体黄金文件（当前是字段级断言，尚未做整文件 diff）
- `test_context`：回放 `.device-probe/backup/PenModssessions-20261027.json`，断言整轮丢弃与 reasoning 随轮
- `test_integration`：`fake_server.py` + 完整协议层 + RequestLog（尚未接）

设备上仍需验证：QML 绑定、宿主注入链、真实网络与性能。
