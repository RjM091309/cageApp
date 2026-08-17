#!/usr/bin/env python3
"""Serve the Flutter release build. Uses PORT (default 4200)."""
import os
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build", "web")
PORT = int(os.environ.get("PORT", "4200"))


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    extensions_map = {
        **SimpleHTTPRequestHandler.extensions_map,
        ".js": "text/javascript",
        ".mjs": "text/javascript",
        ".wasm": "application/wasm",
        ".json": "application/json",
        ".otf": "font/otf",
        ".ttf": "font/ttf",
        ".woff": "font/woff",
        ".woff2": "font/woff2",
    }

    def end_headers(self):
        if self.path.split("?", 1)[0] in ("/", "/index.html"):
            self.send_header("Cache-Control", "no-cache")
        super().end_headers()

    def do_GET(self):
        req_path = self.path.split("?", 1)[0]
        fs_path = self.translate_path(req_path)
        if not os.path.isfile(fs_path):
            self.path = "/index.html"
        return super().do_GET()

    def log_message(self, fmt, *args):
        print("[%s] %s" % (self.log_date_time_string(), fmt % args))


if __name__ == "__main__":
    if not os.path.isdir(ROOT):
        raise SystemExit("Missing %s — run: flutter pub get && flutter build web --release" % ROOT)
    httpd = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    print("Serving Flutter web on http://0.0.0.0:%s from %s" % (PORT, ROOT))
    httpd.serve_forever()
