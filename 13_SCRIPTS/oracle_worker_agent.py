#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path

ALLOWED_TEST_TYPES = {
    "environment_validation",
    "repo_status",
    "repo_refresh",
    "repo_validate",
    "workspace_inventory",
    "terraform_validate",
    "git_log",
}


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def write_json(path: Path, obj: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2), encoding="utf-8")


def run_cmd(cmd: list[str], cwd: Path | None = None) -> tuple[int, str]:
    proc = subprocess.run(
        cmd,
        cwd=str(cwd) if cwd else None,
        capture_output=True,
        text=True,
        check=False,
    )
    output = (proc.stdout or "") + (proc.stderr or "")
    return proc.returncode, output.strip()


def load_packet(packet_path: Path) -> dict:
    try:
        return json.loads(packet_path.read_text(encoding="utf-8"))
    except UnicodeDecodeError:
        return json.loads(packet_path.read_text(encoding="utf-8-sig"))
    except json.JSONDecodeError as exc:
        text = packet_path.read_text(encoding="utf-8-sig")
        if text and text[0] == "\ufeff":
            text = text.lstrip("\ufeff")
        return json.loads(text)


def handle_request(packet_path: Path, node_id: str, shared: Path, repo_dir: Path) -> dict:
    try:
        req = load_packet(packet_path)
    except Exception as exc:  # noqa: BLE001
        return {"packet": str(packet_path), "result": "INVALID_JSON", "error": str(exc)}

    test_id = req.get("test_id", packet_path.stem)
    test_type = req.get("test_type", "")
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
        "validation": [],
    }

    if test_type not in ALLOWED_TEST_TYPES:
        result["result"] = "BLOCKED"
        result["blocked_only_by"].append(f"Test type not allowlisted: {test_type}")
    elif req.get("requires_user_approval"):
        result["result"] = "BLOCKED"
        result["blocked_only_by"].append("requires_user_approval=true")
    elif test_type == "environment_validation":
        code, out = run_cmd(["python3", "13_SCRIPTS/validate_environment.py"], cwd=repo_dir)
        out_path = shared / "logs" / f"{node_id}_{test_id}_environment_validation.txt"
        out_path.write_text(out + "\n", encoding="utf-8")
        result["logs"].append(str(out_path))
        result["artifacts"].append(str(out_path))
        result["result"] = "PASS" if code == 0 else "FAIL"
        result["summary"] = "Environment validation complete."
        result["validation"].append({"command": "python3 13_SCRIPTS/validate_environment.py", "exit_code": code})
    elif test_type == "repo_validate":
        compile_code, compile_out = run_cmd(
            ["python3", "-m", "py_compile", "13_SCRIPTS/oracle_worker_agent.py", "13_SCRIPTS/vm_orchestrator.py"],
            cwd=repo_dir,
        )
        compile_path = shared / "logs" / f"{node_id}_{test_id}_py_compile.txt"
        compile_path.write_text(compile_out + "\n", encoding="utf-8")
        result["logs"].append(str(compile_path))
        if compile_code != 0:
            result["result"] = "FAIL"
            result["blocked_only_by"].append("python3 -m py_compile failed")
            result["validation"].append({"command": "python3 -m py_compile 13_SCRIPTS/oracle_worker_agent.py 13_SCRIPTS/vm_orchestrator.py", "exit_code": compile_code})
        else:
            code, out = run_cmd(["python3", "13_SCRIPTS/validate_environment.py"], cwd=repo_dir)
            out_path = shared / "logs" / f"{node_id}_{test_id}_environment_validation.txt"
            out_path.write_text(out + "\n", encoding="utf-8")
            result["logs"].append(str(out_path))
            result["artifacts"].extend([str(compile_path), str(out_path)])
            result["validation"].append({"command": "python3 -m py_compile 13_SCRIPTS/oracle_worker_agent.py 13_SCRIPTS/vm_orchestrator.py", "exit_code": compile_code})
            result["validation"].append({"command": "python3 13_SCRIPTS/validate_environment.py", "exit_code": code})
            result["result"] = "PASS" if code == 0 else "FAIL"
            result["summary"] = "Repository validation complete."
    elif test_type == "workspace_inventory":
        requested_paths = req.get("inventory_paths") or ["."]
        inventory = {"repo_dir": str(repo_dir), "paths": []}
        for raw_path in requested_paths:
            rel = Path(raw_path)
            candidate = (repo_dir / rel).resolve()
            if repo_dir not in candidate.parents and candidate != repo_dir:
                inventory["paths"].append(
                    {"path": raw_path, "status": "BLOCKED", "error": "path escapes repository root"}
                )
                continue
            if not candidate.exists():
                inventory["paths"].append({"path": raw_path, "status": "MISSING"})
                continue

            if candidate.is_dir():
                children = []
                for entry in sorted(candidate.iterdir(), key=lambda p: p.name.lower()):
                    if entry.name == ".git":
                        continue
                    child = {"name": entry.name, "kind": "dir" if entry.is_dir() else "file"}
                    if entry.is_file():
                        try:
                            child["size_bytes"] = entry.stat().st_size
                        except OSError:
                            child["size_bytes"] = None
                    children.append(child)
                tracked_code, tracked_out = run_cmd(["git", "ls-files", "--", str(rel)], cwd=repo_dir)
                inventory["paths"].append(
                    {
                        "path": raw_path,
                        "status": "OK",
                        "kind": "dir",
                        "children": children,
                        "tracked_files": tracked_out.splitlines() if tracked_out else [],
                        "tracked_exit_code": tracked_code,
                    }
                )
            else:
                try:
                    size_bytes = candidate.stat().st_size
                except OSError:
                    size_bytes = None
                tracked_code, tracked_out = run_cmd(["git", "ls-files", "--", str(rel)], cwd=repo_dir)
                inventory["paths"].append(
                    {
                        "path": raw_path,
                        "status": "OK",
                        "kind": "file",
                        "size_bytes": size_bytes,
                        "tracked_files": tracked_out.splitlines() if tracked_out else [],
                        "tracked_exit_code": tracked_code,
                    }
                )

        status_code, status_out = run_cmd(["git", "status", "--short"], cwd=repo_dir)
        inventory["git_status"] = status_out.splitlines() if status_out else []
        inv_path = shared / "logs" / f"{node_id}_{test_id}_workspace_inventory.json"
        write_json(inv_path, inventory)
        result["logs"].append(str(inv_path))
        result["artifacts"].append(str(inv_path))
        result["result"] = "PASS" if status_code == 0 else "FAIL"
        result["summary"] = "Workspace inventory captured."
        result["validation"].append({"command": "git status --short", "exit_code": status_code})
    elif test_type == "terraform_validate":
        terraform_target = req.get("terraform_target", "oracle")
        terraform_dir = repo_dir / "19_GENERATED_DEPLOYMENT" / "terraform" / terraform_target
        if not terraform_dir.exists():
            result["result"] = "FAIL"
            result["blocked_only_by"].append(f"Terraform target missing: {terraform_target}")
        else:
            terraform_bin = shutil.which("terraform")
            if not terraform_bin:
                candidate = Path.home() / "bin" / "terraform"
                terraform_bin = str(candidate) if candidate.exists() else "terraform"

            init_code, init_out = run_cmd([terraform_bin, "init", "-backend=false"], cwd=terraform_dir)
            init_path = shared / "logs" / f"{node_id}_{test_id}_terraform_init.txt"
            init_path.write_text(init_out + "\n", encoding="utf-8")
            result["logs"].append(str(init_path))
            if init_code != 0:
                result["result"] = "FAIL"
                result["blocked_only_by"].append("terraform init -backend=false failed")
                result["validation"].append({"command": f"{terraform_bin} init -backend=false", "exit_code": init_code})
            else:
                validate_code, validate_out = run_cmd([terraform_bin, "validate"], cwd=terraform_dir)
                validate_path = shared / "logs" / f"{node_id}_{test_id}_terraform_validate.txt"
                validate_path.write_text(validate_out + "\n", encoding="utf-8")
                result["logs"].append(str(validate_path))
                result["artifacts"].extend([str(init_path), str(validate_path)])
                result["validation"].append({"command": f"{terraform_bin} init -backend=false", "exit_code": init_code})
                result["validation"].append({"command": f"{terraform_bin} validate", "exit_code": validate_code})
                result["result"] = "PASS" if validate_code == 0 else "FAIL"
                result["summary"] = f"Terraform validation complete for {terraform_target}."
    elif test_type == "repo_status":
        code, out = run_cmd(["git", "status", "--short"], cwd=repo_dir)
        out_path = shared / "logs" / f"{node_id}_{test_id}_git_status.txt"
        out_path.write_text(out + "\n", encoding="utf-8")
        result["logs"].append(str(out_path))
        result["artifacts"].append(str(out_path))
        result["result"] = "PASS" if code == 0 else "FAIL"
        result["summary"] = "Git status captured."
        result["validation"].append({"command": "git status --short", "exit_code": code})
    elif test_type == "git_log":
        code, out = run_cmd(["git", "log", "--oneline", "-n", "5"], cwd=repo_dir)
        out_path = shared / "logs" / f"{node_id}_{test_id}_git_log.txt"
        out_path.write_text(out + "\n", encoding="utf-8")
        result["logs"].append(str(out_path))
        result["artifacts"].append(str(out_path))
        result["result"] = "PASS" if code == 0 else "FAIL"
        result["summary"] = "Recent Git history captured."
        result["validation"].append({"command": "git log --oneline -n 5", "exit_code": code})
    elif test_type == "repo_refresh":
        pull_code, pull_out = run_cmd(["git", "pull", "--ff-only"], cwd=repo_dir)
        pull_path = shared / "logs" / f"{node_id}_{test_id}_git_pull.txt"
        pull_path.write_text(pull_out + "\n", encoding="utf-8")
        result["logs"].append(str(pull_path))
        if pull_code != 0:
            result["result"] = "FAIL"
            result["blocked_only_by"].append("git pull --ff-only failed")
            result["validation"].append({"command": "git pull --ff-only", "exit_code": pull_code})
        else:
            val_code, val_out = run_cmd(["python3", "13_SCRIPTS/validate_environment.py"], cwd=repo_dir)
            val_path = shared / "logs" / f"{node_id}_{test_id}_environment_validation.txt"
            val_path.write_text(val_out + "\n", encoding="utf-8")
            result["logs"].append(str(val_path))
            result["artifacts"].extend([str(pull_path), str(val_path)])
            result["validation"].append({"command": "git pull --ff-only", "exit_code": pull_code})
            result["validation"].append({"command": "python3 13_SCRIPTS/validate_environment.py", "exit_code": val_code})
            result["result"] = "PASS" if val_code == 0 else "FAIL"
            result["summary"] = "Repo refreshed and environment validated."
    else:
        result["result"] = "BLOCKED"
        result["blocked_only_by"].append(f"Unhandled test type: {test_type}")

    result["finished_at"] = now()
    out = shared / "test_results" / node_id / f"{test_id}.json"
    write_json(out, result)

    archive = packet_path.parent / "_processed"
    archive.mkdir(exist_ok=True)
    shutil.move(str(packet_path), str(archive / packet_path.name))
    return {"packet": str(packet_path), "result": result["result"], "output": str(out)}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--node-id", default="cloud_vm")
    parser.add_argument("--shared-root", default="./shared/CMCB-Shared")
    parser.add_argument("--repo-dir", default="")
    parser.add_argument("--once", action="store_true")
    parser.add_argument("--interval", type=int, default=5)
    args = parser.parse_args()

    shared = Path(args.shared_root).resolve()
    repo_dir = Path(args.repo_dir).expanduser().resolve() if args.repo_dir else Path.home() / "cmcb-work" / "projects" / "cmcb-cross-device-codex"
    req_dir = shared / "test_requests" / args.node_id
    res_dir = shared / "test_results" / args.node_id
    req_dir.mkdir(parents=True, exist_ok=True)
    res_dir.mkdir(parents=True, exist_ok=True)

    while True:
        reports = []
        for packet in sorted(req_dir.glob("*.json")):
            reports.append(handle_request(packet, args.node_id, shared, repo_dir))
        if reports:
            print(json.dumps({"handled": reports}, indent=2))
        if args.once:
            break
        time.sleep(args.interval)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
