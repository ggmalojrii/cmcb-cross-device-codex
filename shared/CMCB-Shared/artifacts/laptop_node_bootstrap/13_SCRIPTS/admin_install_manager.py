#!/usr/bin/env python3
from pathlib import Path
import argparse, json, subprocess, sys
from datetime import datetime, timezone

MANIFEST_PATH = Path("11_ADMIN_INSTALLS/ADMIN_INSTALL_MANIFEST.json")
if not MANIFEST_PATH.exists():
    MANIFEST_PATH = Path("ADMIN_INSTALL_MANIFEST.json")

def now():
    return datetime.now(timezone.utc).isoformat()

def load():
    return json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))

def write_report(name, obj):
    Path("reports").mkdir(exist_ok=True)
    Path("shared/CMCB-Shared/admin_install_results").mkdir(parents=True, exist_ok=True)
    Path("reports", name).write_text(json.dumps(obj, indent=2), encoding="utf-8")
    Path("shared/CMCB-Shared/admin_install_results", name).write_text(json.dumps(obj, indent=2), encoding="utf-8")

def plan(args=None):
    m = load()
    report = {
        "result": "PLAN",
        "timestamp": now(),
        "allow_admin_actions": m.get("global_policy", {}).get("allow_admin_actions", False),
        "windows_enabled": [x for x in m.get("windows_installers", []) if x.get("enabled")],
        "linux_enabled": [x for x in m.get("linux_installers", []) if x.get("enabled")]
    }
    write_report("ADMIN_INSTALL_PLAN.json", report)
    print(json.dumps(report, indent=2))

def run_linux(args=None):
    m = load()
    policy = m.get("global_policy", {})
    if not policy.get("allow_admin_actions"):
        report = {"result": "BLOCKED", "blocked_only_by": ["allow_admin_actions=false"]}
        write_report("ADMIN_INSTALL_REPORT.json", report)
        print(json.dumps(report, indent=2))
        return 1
    results = []
    for item in m.get("linux_installers", []):
        if not item.get("enabled"):
            continue
        if item.get("method") == "apt":
            packages = item.get("packages", [])
            cmd = ["sudo", "apt", "install", "-y", *packages]
            try:
                proc = subprocess.run(cmd, text=True, capture_output=True, timeout=3600)
                results.append({
                    "id": item.get("id"),
                    "cmd": " ".join(cmd),
                    "returncode": proc.returncode,
                    "stdout_tail": proc.stdout[-4000:],
                    "stderr_tail": proc.stderr[-4000:]
                })
            except Exception as e:
                results.append({"id": item.get("id"), "error": str(e)})
    report = {"result": "DONE", "timestamp": now(), "results": results}
    write_report("ADMIN_INSTALL_REPORT.json", report)
    print(json.dumps(report, indent=2))
    return 0

parser = argparse.ArgumentParser()
sub = parser.add_subparsers(dest="cmd")
sub.add_parser("plan")
sub.add_parser("run-linux")
args = parser.parse_args()
if args.cmd == "run-linux":
    raise SystemExit(run_linux(args))
else:
    plan(args)
