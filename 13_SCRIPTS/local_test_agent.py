#!/usr/bin/env python3
from pathlib import Path
import argparse, json, time, shutil, subprocess
from datetime import datetime, timezone

ALLOWED_TEST_TYPES = {
    "file_inventory",
    "artifact_presence",
    "minecraft_client_manual",
    "minecraft_log_collect",
    "visual_manual"
}

def now():
    return datetime.now(timezone.utc).isoformat()

def write_json(path, obj):
    p = Path(path)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(obj, indent=2), encoding="utf-8")
    return p

def handle_request(packet_path, node_id, shared):
    try:
        req = json.loads(packet_path.read_text(encoding="utf-8"))
    except Exception as e:
        return {"packet": str(packet_path), "result": "INVALID_JSON", "error": str(e)}

    test_id = req.get("test_id", packet_path.stem)
    test_type = req.get("test_type")
    result = {
        "packet_type": "CMCB_TEST_RESULT",
        "schema_version": "1.0",
        "test_id": test_id,
        "source_actor": f"{node_id.upper()}_TEST_NODE",
        "target_actor": "CODEX_VM",
        "result": "SKIPPED",
        "logs": [],
        "artifacts": [],
        "screenshots": [],
        "summary": "",
        "blocked_only_by": [],
        "started_at": now(),
        "finished_at": "",
        "validation": []
    }

    if test_type not in ALLOWED_TEST_TYPES:
        result["result"] = "BLOCKED"
        result["blocked_only_by"].append(f"Test type not allowlisted: {test_type}")
    elif req.get("requires_user_approval"):
        result["result"] = "BLOCKED"
        result["blocked_only_by"].append("requires_user_approval=true")
    elif test_type == "file_inventory":
        files = []
        for p in shared.rglob("*"):
            if p.is_file():
                try:
                    files.append(str(p.relative_to(shared)))
                except Exception:
                    files.append(str(p))
        inv_path = shared / "logs" / f"{node_id}_{test_id}_file_inventory.json"
        write_json(inv_path, {"node": node_id, "files": files[:5000], "count": len(files)})
        result["result"] = "PASS"
        result["artifacts"].append(str(inv_path))
        result["summary"] = f"Inventory complete: {len(files)} files."
    elif test_type == "artifact_presence":
        artifact = req.get("artifact", "")
        if artifact and Path(artifact).exists():
            result["result"] = "PASS"
            result["summary"] = f"Artifact exists: {artifact}"
        else:
            result["result"] = "FAIL"
            result["blocked_only_by"].append(f"Artifact missing: {artifact}")
    elif test_type == "minecraft_log_collect":
        # Collect common log locations if present.
        candidates = [
            Path.home() / "AppData/Roaming/.minecraft/logs/latest.log",
            Path.home() / ".minecraft/logs/latest.log"
        ]
        copied = []
        for c in candidates:
            if c.exists():
                dest = shared / "logs" / f"{node_id}_{test_id}_{c.name}"
                shutil.copy2(c, dest)
                copied.append(str(dest))
        result["logs"] = copied
        result["result"] = "PASS" if copied else "BLOCKED"
        if copied:
            result["summary"] = "Collected Minecraft logs."
        else:
            result["blocked_only_by"].append("No known Minecraft latest.log found.")
    else:
        result["result"] = "BLOCKED"
        result["blocked_only_by"].append(f"Manual test type: {test_type}")

    result["finished_at"] = now()
    out = shared / "test_results" / node_id / f"{test_id}.json"
    write_json(out, result)
    archive = packet_path.parent / "_processed"
    archive.mkdir(exist_ok=True)
    shutil.move(str(packet_path), str(archive / packet_path.name))
    return {"packet": str(packet_path), "result": result["result"], "output": str(out)}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--node-id", required=True, choices=["desktop", "laptop"])
    parser.add_argument("--shared-root", default="./shared/CMCB-Shared")
    parser.add_argument("--once", action="store_true")
    parser.add_argument("--interval", type=int, default=5)
    args = parser.parse_args()

    shared = Path(args.shared_root)
    req_dir = shared / "test_requests" / args.node_id
    req_dir.mkdir(parents=True, exist_ok=True)
    (shared / "test_results" / args.node_id).mkdir(parents=True, exist_ok=True)

    while True:
        reports = []
        for packet in sorted(req_dir.glob("*.json")):
            reports.append(handle_request(packet, args.node_id, shared))
        if reports:
            print(json.dumps({"handled": reports}, indent=2))
        if args.once:
            break
        time.sleep(args.interval)

if __name__ == "__main__":
    main()
