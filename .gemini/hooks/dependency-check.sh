#!/usr/bin/env bash
# MWP dependency-check hook — scan for known vulnerable npm and pip packages
# Runs on PreToolUse before installs or lockfile changes.
# Fails silently if tools aren't installed so it never blocks unrelated work.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
if [[ -z "$REPO_ROOT" ]]; then exit 0; fi

AUDIT_LOG="$REPO_ROOT/rules/audit.log"
mkdir -p "$(dirname "$AUDIT_LOG")"
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")
EXIT_CODE=0

echo "[dependency-check] Scanning for known vulnerabilities..."

# ── npm / Node ─────────────────────────────────────────────────────────────
if [[ -f "$REPO_ROOT/package-lock.json" ]] || [[ -f "$REPO_ROOT/package.json" ]]; then
  if command -v npm &>/dev/null; then
    echo "[dependency-check] Running npm audit..."
    cd "$REPO_ROOT"
    # --audit-level=high: only fail on high/critical, not moderate
    if ! npm audit --audit-level=high --json 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
vulns = data.get('metadata', {}).get('vulnerabilities', {})
high = vulns.get('high', 0) + vulns.get('critical', 0)
if high > 0:
    print(f'  ⛔  {high} high/critical npm vulnerabilities found')
    sys.exit(1)
else:
    print(f'  ✅  npm: no high/critical vulnerabilities')
"; then
      EXIT_CODE=1
    fi
  fi
fi

# ── pip / Python ───────────────────────────────────────────────────────────
if [[ -f "$REPO_ROOT/requirements.txt" ]] || [[ -f "$REPO_ROOT/environment.yml" ]]; then
  if command -v pip &>/dev/null && pip show pip-audit &>/dev/null 2>&1; then
    echo "[dependency-check] Running pip-audit..."
    cd "$REPO_ROOT"
    REQ_FILE="requirements.txt"
    [[ -f "$REQ_FILE" ]] || REQ_FILE="environment.yml"
    if ! pip-audit -r "$REQ_FILE" --format=json 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
vulns = data.get('dependencies', [])
found = [v for d in vulns for v in d.get('vulns', [])]
if found:
    print(f'  ⛔  {len(found)} pip vulnerabilities found')
    for v in found[:5]:
        print(f'     {v.get(\"id\", \"\")} — {v.get(\"fix_versions\", [])}')
    sys.exit(1)
else:
    print(f'  ✅  pip: no known vulnerabilities')
"; then
      EXIT_CODE=1
    fi
  else
    echo "[dependency-check] pip-audit not installed — skipping (pip install pip-audit to enable)"
  fi
fi

if [[ "$EXIT_CODE" -eq 0 ]]; then
  echo "[dependency-check] ✅ Dependency scan passed."
  echo "[$TIMESTAMP] dependency-check: PASSED" >> "$AUDIT_LOG"
else
  echo ""
  echo "[dependency-check] ❌ Vulnerable dependencies detected. Run 'npm audit fix' or update requirements.txt."
  echo "[$TIMESTAMP] dependency-check: FAILED" >> "$AUDIT_LOG"
fi

exit $EXIT_CODE
