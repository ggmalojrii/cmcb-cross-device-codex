#!/usr/bin/env python3
from pathlib import Path
import argparse, json, hashlib, uuid
from datetime import datetime, timezone

def now():
    return datetime.now(timezone.utc).isoformat()

def sha256_file(path):
    p = Path(path)
    if not p.exists() or not p.is_file():
        return ""
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def write_json(path, obj):
    p = Path(path)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(obj, indent=2), encoding="utf-8")
    return p

def create_test(args):
    shared = Path(args.shared_root)
    target = args.target.lower()
    if target not in {"desktop", "laptop"}:
        raise SystemExit("target must be desktop or laptop")
    test_id = "test_" + uuid.uuid4().hex[:10]
    packet = {
        "packet_type": "CMCB_TEST_REQUEST",
        "schema_version": "1.0",
        "test_id": test_id,
        "source_actor": "CODEX_VM",
        "target_actor": f"{target.upper()}_TEST_NODE",
        "project": args.project,
        "artifact": args.artifact,
        "artifact_sha256": sha256_file(args.artifact),
        "test_type": args.test_type,
        "steps": args.steps or [],
        "expected_outputs": ["CMCB_TEST_RESULT"],
        "risk_level": args.risk,
        "requires_user_approval": args.requires_user_approval,
        "timeout_minutes": args.timeout,
        "allowed_commands": [],
        "stop_conditions": ["admin_prompt", "credential_prompt", "destructive_action", "unknown_download", "timeout", "manual_review_required"],
        "created_at": now()
    }
    out = shared / "test_requests" / target / f"{test_id}.json"
    write_json(out, packet)
    print(json.dumps({"result": "TEST_REQUEST_CREATED", "path": str(out), "test_id": test_id}, indent=2))

def collect_results(args):
    shared = Path(args.shared_root)
    results = []
    for node in ["desktop", "laptop"]:
        folder = shared / "test_results" / node
        for p in folder.glob("*.json"):
            try:
                data = json.loads(p.read_text(encoding="utf-8"))
                results.append({"node": node, "path": str(p), "result": data.get("result"), "test_id": data.get("test_id"), "summary": data.get("summary")})
            except Exception as e:
                results.append({"node": node, "path": str(p), "result": "INVALID_JSON", "error": str(e)})
    report = {"generated_at": now(), "results": results}
    write_json("reports/VM_COLLECTED_TEST_RESULTS.json", report)
    print(json.dumps(report, indent=2))

parser = argparse.ArgumentParser()
sub = parser.add_subparsers(dest="cmd")
c = sub.add_parser("create-test")
c.add_argument("--target", required=True)
c.add_argument("--test-type", required=True)
c.add_argument("--artifact", default="")
c.add_argument("--project", default="")
c.add_argument("--shared-root", default="./shared/CMCB-Shared")
c.add_argument("--risk", default="LOW")
c.add_argument("--timeout", type=int, default=20)
c.add_argument("--steps", nargs="*", default=[])
c.add_argument("--requires-user-approval", action="store_true")
r = sub.add_parser("collect-results")
r.add_argument("--shared-root", default="./shared/CMCB-Shared")
args = parser.parse_args()

if args.cmd == "create-test":
    create_test(args)
elif args.cmd == "collect-results":
    collect_results(args)
else:
    parser.print_help()
