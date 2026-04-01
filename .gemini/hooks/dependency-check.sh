#!/usr/bin/env bash
# MWP dependency-check hook — scan for known vulnerable npm and pip packages.
# STDOUT: JSON only. ALL logging goes to STDERR.
# Fails silently if tools aren't installed.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
if [[ -z "$REPO_ROOT" ]]; then exit 0; fi

AUDIT_LOG="$REPO_ROOT/rules/audit.log"
mkdir -p "$(dirname "$AUDIT_LOG")"
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")
EXIT_CODE=0

echo "[dependency-check] Scanning for known vulnerabilities..." >&2

# ── npm / Node ────────────────────────────────────────────────────────────────
if [[ -f "$REPO_ROOT/package-lock.json" ]] || [[ -f "$REPO_ROOT/package.json" ]]; then
  if command -v npm &>/dev/null; then
    echo "[dependency-check] Running npm audit..." >&2
    cd "$REPO_ROOT"
    NPM_JSON=$(npm audit --audit-level=high --json 2>/dev/null || true)
    HIGH=$(echo "$NPM_JSON" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    v = d.get('metadata', {}).get('vulnerabilities', {})
    print(v.get('high', 0) + v.get('critical', 0))
except Exception:
    print(0)
" 2>/dev/null || echo "0")
    if [[ "$HIGH" -gt 0 ]]; then
      echo "  ⛔  $HIGH high/critical npm vulnerabilities found" >&2
      EXIT_CODE=1
    else
      echo "  ✅  npm: no high/critical vulnerabilities" >&2
    fi
  fi
fi

# ── pip / Python ──────────────────────────────────────────────────────────────
if [[ -f "$REPO_ROOT/requirements.txt" ]] || [[ -f "$REPO_ROOT/environment.yml" ]]; then
  if command -v pip-audit &>/dev/null; then
    echo "[dependency-check] Running pip-audit..." >&2
    cd "$REPO_ROOT"
    REQ_FILE="requirements.txt"
    [[ -f "$REQ_FILE" ]] || REQ_FILE="environment.yml"
    PIP_JSON=$(pip-audit -r "$REQ_FILE" --format=json 2>/dev/null || true)
    VULN_COUNT=$(echo "$PIP_JSON" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    found = [v for d in data.get('dependencies',[]) for v in d.get('vulns',[])]
    print(len(found))
except Exception:
    print(0)
" 2>/dev/null || echo "0")
    if [[ "$VULN_COUNT" -gt 0 ]]; then
      echo "  ⛔  $VULN_COUNT pip vulnerabilities found — run 'pip-audit -r requirements.txt' for details" >&2
      EXIT_CODE=1
    else
      echo "  ✅  pip: no known vulnerabilities" >&2
    fi
  else
    echo "[dependency-check] pip-audit not installed — skipping (pip install pip-audit to enable)" >&2
  fi
fi

if [[ "$EXIT_CODE" -eq 0 ]]; then
  echo "[dependency-check] ✅ Dependency scan passed." >&2
  echo "[$TIMESTAMP] dependency-check: PASSED" >> "$AUDIT_LOG"
else
  echo "[dependency-check] ❌ Vulnerable dependencies detected." >&2
  echo "[$TIMESTAMP] dependency-check: FAILED" >> "$AUDIT_LOG"
fi

exit $EXIT_CODE
