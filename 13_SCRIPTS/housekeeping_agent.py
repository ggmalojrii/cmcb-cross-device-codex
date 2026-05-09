#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import shutil
import time
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ALLOWED_ROOT_NAMES = {"repo", "handoff"}
ALLOWED_OPERATIONS = {"list", "add", "edit", "delete", "move", "rename"}
SAFE_DENY_NAMES = {".git", ".env", ".env.example"}
SAFE_DENY_SUFFIXES = {".pem", ".key", ".p12", ".pfx"}


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def write_json(path: Path, obj: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2), encoding="utf-8")


def read_json(path: Path) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8-sig")
    return json.loads(text)


def resolve_root(root_name: str, repo_dir: Path, handoff_dir: Path) -> Path:
    if root_name == "repo":
        return repo_dir
    if root_name == "handoff":
        return handoff_dir
    raise ValueError(f"unsupported root: {root_name}")


def safe_target(root: Path, rel_path: str) -> Path:
    rel = Path(rel_path)
    if rel.is_absolute():
        raise ValueError("absolute paths are not allowed")
    if ".." in rel.parts:
        raise ValueError("path traversal is not allowed")
    candidate = (root / rel).resolve()
    if candidate != root and root not in candidate.parents:
        raise ValueError("path escapes allowed root")
    for part in candidate.parts:
        if part in SAFE_DENY_NAMES:
            raise ValueError("path points at a denied name")
    if candidate.suffix.lower() in SAFE_DENY_SUFFIXES:
        raise ValueError("path points at a denied secret-like file type")
    return candidate


def capture_listing(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {"status": "MISSING"}
    if path.is_file():
        return {
            "status": "OK",
            "kind": "file",
            "size_bytes": path.stat().st_size,
        }
    children = []
    for entry in sorted(path.iterdir(), key=lambda p: p.name.lower()):
        if entry.name == ".git":
            continue
        item = {"name": entry.name, "kind": "dir" if entry.is_dir() else "file"}
        if entry.is_file():
            item["size_bytes"] = entry.stat().st_size
        children.append(item)
    return {"status": "OK", "kind": "dir", "children": children}


def backup_file(src: Path, backup_root: Path, rel_path: str) -> str | None:
    if not src.exists() or not src.is_file():
        return None
    backup_path = backup_root / rel_path
    backup_path.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, backup_path)
    return str(backup_path)


def apply_request(req: dict[str, Any], repo_dir: Path, handoff_dir: Path, shared_root: Path) -> dict[str, Any]:
    result: dict[str, Any] = {
        "packet_type": "CMCB_HOUSEKEEPING_RESULT",
        "schema_version": "1.0",
        "request_id": req.get("request_id", f"request_{uuid.uuid4().hex[:8]}"),
        "result": "SKIPPED",
        "started_at": now(),
        "finished_at": "",
        "logs": [],
        "artifacts": [],
        "blocked_only_by": [],
        "changes": [],
    }

    root_name = req.get("target_root", "")
    operation = req.get("operation", "")
    if root_name not in ALLOWED_ROOT_NAMES:
        result["result"] = "BLOCKED"
        result["blocked_only_by"].append(f"unsupported root: {root_name}")
        return result
    if operation not in ALLOWED_OPERATIONS:
        result["result"] = "BLOCKED"
        result["blocked_only_by"].append(f"unsupported operation: {operation}")
        return result

    root = resolve_root(root_name, repo_dir, handoff_dir)
    rel_path = req.get("path", "").strip()
    dest_rel = req.get("destination_path", "").strip()
    dry_run = bool(req.get("dry_run", True))
    confirm_destructive = bool(req.get("confirm_destructive", False))
    content_mode = req.get("content_mode", "replace")
    content = req.get("content", "")

    try:
        target = safe_target(root, rel_path) if rel_path else root
        destination = safe_target(root, dest_rel) if dest_rel else None
    except ValueError as exc:
        result["result"] = "BLOCKED"
        result["blocked_only_by"].append(str(exc))
        return result

    if operation in {"delete", "move", "rename"} and not confirm_destructive:
        result["result"] = "BLOCKED"
        result["blocked_only_by"].append("destructive action not confirmed")
        return result

    backup_root = shared_root / "housekeeping" / "backups" / result["request_id"]

    try:
        if operation == "list":
            result["result"] = "PASS"
            result["summary"] = "Listing captured."
            result["artifacts"].append("inline listing")
            result["listing"] = capture_listing(target)
            result["changes"].append({"operation": "list", "path": rel_path or "."})
        elif operation == "add":
            if dry_run:
                result["result"] = "PASS"
                result["summary"] = "Dry run add planned."
                result["changes"].append({"operation": "add", "path": rel_path, "dry_run": True})
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                if target.exists():
                    backup = backup_file(target, backup_root, rel_path)
                    if backup:
                        result["artifacts"].append(backup)
                target.write_text(content, encoding="utf-8")
                result["result"] = "PASS"
                result["summary"] = "File created."
                result["changes"].append({"operation": "add", "path": rel_path, "content_mode": content_mode})
        elif operation == "edit":
            if dry_run:
                result["result"] = "PASS"
                result["summary"] = "Dry run edit planned."
                result["changes"].append({"operation": "edit", "path": rel_path, "dry_run": True})
            else:
                if not target.exists():
                    result["result"] = "BLOCKED"
                    result["blocked_only_by"].append("target file does not exist")
                else:
                    backup = backup_file(target, backup_root, rel_path)
                    if backup:
                        result["artifacts"].append(backup)
                    original = target.read_text(encoding="utf-8")
                    if content_mode == "append":
                        updated = original + content
                    elif content_mode == "prepend":
                        updated = content + original
                    else:
                        updated = content
                    target.write_text(updated, encoding="utf-8")
                    result["result"] = "PASS"
                    result["summary"] = "File updated."
                    result["changes"].append({"operation": "edit", "path": rel_path, "content_mode": content_mode})
        elif operation == "delete":
            if dry_run:
                result["result"] = "PASS"
                result["summary"] = "Dry run delete planned."
                result["changes"].append({"operation": "delete", "path": rel_path, "dry_run": True})
            else:
                if not target.exists():
                    result["result"] = "BLOCKED"
                    result["blocked_only_by"].append("target file missing")
                elif target.is_dir():
                    if any(target.iterdir()):
                        result["result"] = "BLOCKED"
                        result["blocked_only_by"].append("directory not empty")
                    else:
                        target.rmdir()
                        result["result"] = "PASS"
                        result["summary"] = "Directory removed."
                        result["changes"].append({"operation": "delete", "path": rel_path})
                else:
                    backup = backup_file(target, backup_root, rel_path)
                    if backup:
                        result["artifacts"].append(backup)
                    target.unlink()
                    result["result"] = "PASS"
                    result["summary"] = "File deleted."
                    result["changes"].append({"operation": "delete", "path": rel_path})
        elif operation in {"move", "rename"}:
            if destination is None:
                result["result"] = "BLOCKED"
                result["blocked_only_by"].append("destination_path is required")
            elif dry_run:
                result["result"] = "PASS"
                result["summary"] = "Dry run move planned."
                result["changes"].append({"operation": operation, "from": rel_path, "to": dest_rel, "dry_run": True})
            else:
                if not target.exists():
                    result["result"] = "BLOCKED"
                    result["blocked_only_by"].append("source path missing")
                else:
                    destination.parent.mkdir(parents=True, exist_ok=True)
                    shutil.move(str(target), str(destination))
                    result["result"] = "PASS"
                    result["summary"] = "Path moved."
                    result["changes"].append({"operation": operation, "from": rel_path, "to": dest_rel})
        else:
            result["result"] = "BLOCKED"
            result["blocked_only_by"].append(f"unhandled operation: {operation}")
    except Exception as exc:  # noqa: BLE001
        result["result"] = "FAIL"
        result["blocked_only_by"].append(str(exc))

    result["finished_at"] = now()
    return result


def process_queue(shared_root: Path, repo_dir: Path, handoff_dir: Path, node_id: str, once: bool, interval: int) -> int:
    queue_root = shared_root / "housekeeping" / "requests" / "approved"
    results_root = shared_root / "housekeeping" / "results"
    logs_root = shared_root / "housekeeping" / "logs"
    processed_root = queue_root / "_processed"
    for folder in [queue_root, results_root, logs_root, processed_root]:
        folder.mkdir(parents=True, exist_ok=True)

    while True:
        handled = []
        for packet_path in sorted(queue_root.glob("*.json")):
            try:
                req = read_json(packet_path)
                result = apply_request(req, repo_dir, handoff_dir, shared_root)
            except Exception as exc:  # noqa: BLE001
                result = {
                    "packet_type": "CMCB_HOUSEKEEPING_RESULT",
                    "schema_version": "1.0",
                    "request_id": packet_path.stem,
                    "result": "INVALID_JSON",
                    "error": str(exc),
                    "started_at": now(),
                    "finished_at": now(),
                }

            out = results_root / f"{packet_path.stem}.json"
            write_json(out, result)
            log_path = logs_root / f"{node_id}_{packet_path.stem}.json"
            write_json(log_path, result)
            shutil.move(str(packet_path), str(processed_root / packet_path.name))
            handled.append({"packet": str(packet_path), "result": result.get("result"), "output": str(out)})

        if handled:
            print(json.dumps({"handled": handled}, indent=2))
        if once:
            break
        time.sleep(interval)

    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--node-id", default="housekeeping_agent")
    parser.add_argument("--shared-root", default="./shared/CMCB-Shared")
    parser.add_argument("--repo-dir", default="")
    parser.add_argument("--handoff-dir", default="")
    parser.add_argument("--once", action="store_true")
    parser.add_argument("--interval", type=int, default=5)
    args = parser.parse_args()

    shared_root = Path(args.shared_root).expanduser().resolve()
    repo_dir = Path(args.repo_dir).expanduser().resolve() if args.repo_dir else Path.cwd().resolve()
    handoff_dir = Path(args.handoff_dir).expanduser().resolve() if args.handoff_dir else shared_root / "handoffs" / "chatgpt-online"

    if not shared_root.exists():
        raise SystemExit(f"shared root not found: {shared_root}")

    return process_queue(shared_root, repo_dir, handoff_dir, args.node_id, args.once, args.interval)


if __name__ == "__main__":
    raise SystemExit(main())
