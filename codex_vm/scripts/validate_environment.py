#!/usr/bin/env python3
from pathlib import Path
import json, shutil, subprocess, platform
from datetime import datetime, timezone

checks = {
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "platform": platform.platform(),
    "python": True,
    "git": bool(shutil.which("git")),
    "java": bool(shutil.which("java")),
    "node": bool(shutil.which("node")),
    "npm": bool(shutil.which("npm")),
    "codex": bool(shutil.which("codex")),
    "tailscale": bool(shutil.which("tailscale")),
    "syncthing": bool(shutil.which("syncthing")),
    "shared_folder_exists": Path("shared/CMCB-Shared").exists()
}
checks["result"] = "PASS" if checks["git"] and checks["python"] and checks["shared_folder_exists"] else "WARN"
Path("reports").mkdir(exist_ok=True)
Path("reports/ENVIRONMENT_VALIDATION_REPORT.json").write_text(json.dumps(checks, indent=2), encoding="utf-8")
print(json.dumps(checks, indent=2))
