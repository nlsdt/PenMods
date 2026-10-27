#!/usr/bin/env python3
"""本地假 AI 服务，用于 P0.2 验收：返回 400 或一条最小 SSE 流。

用法：
    python3 tests/fake_server.py --port 18080 --status 400 \
        --body '{"error":{"message":"Invalid tool_calls sequence"}}'
    python3 tests/fake_server.py --port 18080 --sse

只打印方法/路径/字节数，不打印请求体与 Authorization，避免把 key 带到终端。
"""

import argparse
import json
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class Handler(BaseHTTPRequestHandler):
    server_version = "PenModsFake/1.0"

    def do_POST(self):
        length = int(self.headers.get("Content-Length", "0") or 0)
        if length:
            self.rfile.read(length)
        auth = self.headers.get("Authorization", "")
        print(
            f"[fake] POST {self.path} status={self.server.args.status} "
            f"auth={'yes' if auth else 'no'} bytes={length}",
            flush=True,
        )

        if self.server.args.sse:
            self._send_sse()
            return

        payload = self.server.args.body.encode("utf-8")
        self.send_response(self.server.args.status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def _send_sse(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream; charset=utf-8")
        self.send_header("Cache-Control", "no-cache")
        self.end_headers()

        events = [
            {"choices": [{"index": 0, "delta": {"content": "fake "}}]},
            {"choices": [{"index": 0, "delta": {"content": "stream"}}]},
            {
                "choices": [{"index": 0, "delta": {}, "finish_reason": "stop"}],
                "usage": {"prompt_tokens": 1, "completion_tokens": 2, "total_tokens": 3},
            },
        ]
        for event in events:
            self.wfile.write(f"data: {json.dumps(event, ensure_ascii=False)}\n\n".encode("utf-8"))
            self.wfile.flush()
            time.sleep(0.05)
        self.wfile.write(b"data: [DONE]\n\n")
        self.wfile.flush()

    def log_message(self, fmt, *args):
        return


def main():
    parser = argparse.ArgumentParser(description="PenMods fake AI endpoint")
    parser.add_argument("--port", type=int, default=18080)
    parser.add_argument("--status", type=int, default=400)
    parser.add_argument(
        "--body",
        default='{"error":{"message":"fake 400 for PenMods P0.2"}}',
        help="非 SSE 模式返回的响应体",
    )
    parser.add_argument("--sse", action="store_true", help="返回一条最小 SSE 流")
    args = parser.parse_args()

    server = ThreadingHTTPServer(("127.0.0.1", args.port), Handler)
    server.args = args
    print(f"[fake] listening on http://127.0.0.1:{args.port} status={args.status} sse={args.sse}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
