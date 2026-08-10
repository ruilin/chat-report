#!/usr/bin/env python3
"""开发期转发代理：让手机借 Mac 的网络访问 api.z.ai。

用法：
    python3 tool/dev_proxy.py                 # 监听 127.0.0.1:8899
    adb reverse tcp:8899 tcp:8899             # 手机 127.0.0.1:8899 -> Mac

App 端点列表（lib/config/api_key.dart 的 zaiEndpoints）已包含
http://127.0.0.1:8899/...，直连 z.ai 失败时会自动落到这里。
仅监听回环地址，不会把 key 暴露到局域网。
"""
import http.server
import urllib.request

UPSTREAM = "https://api.z.ai"
PORT = 8899


class Handler(http.server.BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length)
        req = urllib.request.Request(
            UPSTREAM + self.path,
            data=body,
            method="POST",
            headers={
                "Content-Type": self.headers.get("Content-Type", "application/json"),
                "Authorization": self.headers.get("Authorization", ""),
            },
        )
        try:
            with urllib.request.urlopen(req, timeout=110) as resp:
                data = resp.read()
                self.send_response(resp.status)
                self.send_header("Content-Type",
                                 resp.headers.get("Content-Type", "application/json"))
                self.send_header("Content-Length", str(len(data)))
                self.end_headers()
                self.wfile.write(data)
        except urllib.error.HTTPError as e:
            data = e.read()
            self.send_response(e.code)
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)
        except Exception as e:  # noqa: BLE001
            msg = str(e).encode()
            self.send_response(502)
            self.send_header("Content-Length", str(len(msg)))
            self.end_headers()
            self.wfile.write(msg)

    def log_message(self, fmt, *args):
        print(f"[proxy] {fmt % args}")


if __name__ == "__main__":
    print(f"[proxy] forwarding 127.0.0.1:{PORT} -> {UPSTREAM}")
    http.server.ThreadingHTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
