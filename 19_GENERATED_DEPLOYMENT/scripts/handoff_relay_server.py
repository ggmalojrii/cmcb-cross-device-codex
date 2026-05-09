#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import uuid
from datetime import datetime, timezone
from http import HTTPStatus
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any


SENSITIVE_KEY = re.compile(r"(password|passwd|secret|token|cookie|credential|private|key)", re.I)


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def sanitize(value: Any) -> Any:
    if isinstance(value, dict):
        clean = {}
        for key, item in value.items():
            if SENSITIVE_KEY.search(str(key)):
                clean[key] = "[REDACTED]"
            else:
                clean[key] = sanitize(item)
        return clean
    if isinstance(value, list):
        return [sanitize(item) for item in value[:100]]
    if isinstance(value, str):
        return value[:4000]
    return value


class HandoffHandler(SimpleHTTPRequestHandler):
    server_version = "CMCBHandoff/1.0"

    def __init__(self, *args: Any, directory: str | None = None, **kwargs: Any) -> None:
        super().__init__(*args, directory=directory, **kwargs)

    def list_directory(self, path: str):  # noqa: ANN001
        self.send_error(HTTPStatus.FORBIDDEN, "Directory listing disabled")
        return None

    def end_headers(self) -> None:
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Referrer-Policy", "no-referrer")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    @property
    def checkins_dir(self) -> Path:
        return self.server.checkins_dir  # type: ignore[attr-defined]

    def do_GET(self) -> None:
        if self.path.split("?", 1)[0] == "/api/latest-checkin":
            latest = self.checkins_dir / "latest_laptop_checkin.json"
            if not latest.exists():
                self._json({"ok": False, "error": "no check-ins yet"}, HTTPStatus.NOT_FOUND)
                return
            self._json(json.loads(latest.read_text(encoding="utf-8")))
            return
        super().do_GET()

    def do_POST(self) -> None:
        endpoint = self.path.split("?", 1)[0]
        if endpoint != "/api/laptop-checkin":
            self._json({"ok": False, "error": "unknown endpoint"}, HTTPStatus.NOT_FOUND)
            return

        try:
            length = int(self.headers.get("content-length", "0"))
        except ValueError:
            length = 0
        if length <= 0 or length > 1024 * 1024:
            self._json({"ok": False, "error": "invalid content length"}, HTTPStatus.BAD_REQUEST)
            return

        raw = self.rfile.read(length)
        try:
            payload = json.loads(raw.decode("utf-8"))
        except Exception as exc:  # noqa: BLE001
            self._json({"ok": False, "error": f"invalid json: {exc}"}, HTTPStatus.BAD_REQUEST)
            return

        record = {
            "packet_type": "CMCB_LAPTOP_CHECKIN",
            "schema_version": "1.0",
            "received_at": now(),
            "source": "public_handoff_relay",
            "client": {
                "remote_address": self.client_address[0],
                "user_agent": self.headers.get("user-agent", ""),
            },
            "payload": sanitize(payload),
        }

        self.checkins_dir.mkdir(parents=True, exist_ok=True)
        stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
        out = self.checkins_dir / f"laptop_checkin_{stamp}_{uuid.uuid4().hex[:8]}.json"
        text = json.dumps(record, indent=2)
        out.write_text(text, encoding="utf-8")
        (self.checkins_dir / "latest_laptop_checkin.json").write_text(text, encoding="utf-8")
        self._json({"ok": True, "path": out.name, "received_at": record["received_at"]})

    def _json(self, obj: Any, status: HTTPStatus = HTTPStatus.OK) -> None:
        data = json.dumps(obj, indent=2).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--directory", required=True)
    parser.add_argument("--checkins-dir", required=True)
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8765)
    args = parser.parse_args()

    root = Path(args.directory).resolve()
    checkins_dir = Path(args.checkins_dir).resolve()
    if not root.is_dir():
        raise SystemExit(f"handoff directory not found: {root}")

    class BoundHandler(HandoffHandler):
        def __init__(self, *handler_args: Any, **handler_kwargs: Any) -> None:
            super().__init__(*handler_args, directory=str(root), **handler_kwargs)

    server = ThreadingHTTPServer((args.host, args.port), BoundHandler)
    server.checkins_dir = checkins_dir  # type: ignore[attr-defined]
    print(f"Serving CMCB handoff from {root} on http://{args.host}:{args.port}", flush=True)
    print(f"Check-ins directory: {checkins_dir}", flush=True)
    server.serve_forever()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

