#!/usr/bin/env bash
# MWP test-on-change hook — run relevant tests when src/ files change.
# STDOUT: JSON only. ALL logging goes to STDERR.
# Only runs when source files change — skips docs, ops, data, templates.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
if [[ -z "$REPO_ROOT" ]]; then exit 0; fi

cd "$REPO_ROOT"

AUDIT_LOG="$REPO_ROOT/rules/audit.log"
mkdir -p "$(dirname "$AUDIT_LOG")"
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")

CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || git diff --name-only 2>/dev/null || echo "")

if [[ -z "$CHANGED_FILES" ]]; then
  echo "[test-on-change] No changed files — skipping." >&2
  exit 0
fi

# Only react to src/ changes — skip docs, ops, planning files
SRC_CHANGES=$(echo "$CHANGED_FILES" | grep -E '^(src|Folder-Structure-.*)' | grep -E '\.(py|ts|tsx|r|R|js|jsx)$' || true)

if [[ -z "$SRC_CHANGES" ]]; then
  echo "[test-on-change] No src/ changes — skipping tests." >&2
  exit 0
fi

echo "[test-on-change] src/ changes detected:" >&2
echo "$SRC_CHANGES" >&2

EXIT_CODE=0

# ── Python — pytest ──────────────────────────────────────────────────────────
PY_CHANGES=$(echo "$SRC_CHANGES" | grep '\.py$' || true)
if [[ -n "$PY_CHANGES" ]] && command -v pytest &>/dev/null; then
  echo "[test-on-change] Running pytest..." >&2
  if [[ -d "$REPO_ROOT/src/tests" ]]; then
    pytest "$REPO_ROOT/src/tests" -q --tb=short 2>&1 >&2 || EXIT_CODE=1
  elif [[ -d "$REPO_ROOT/tests" ]]; then
    pytest "$REPO_ROOT/tests" -q --tb=short 2>&1 >&2 || EXIT_CODE=1
  else
    echo "[test-on-change] No tests/ directory found — skipping pytest." >&2
  fi
fi

# ── TypeScript / JavaScript — npm test ───────────────────────────────────────
TS_CHANGES=$(echo "$SRC_CHANGES" | grep -E '\.(ts|tsx|js|jsx)$' || true)
if [[ -n "$TS_CHANGES" ]] && [[ -f "$REPO_ROOT/package.json" ]]; then
  echo "[test-on-change] Running npm test..." >&2
  npm test --silent 2>&1 >&2 || EXIT_CODE=1
fi

# ── R — testthat ─────────────────────────────────────────────────────────────
R_CHANGES=$(echo "$SRC_CHANGES" | grep -E '\.(r|R)$' || true)
if [[ -n "$R_CHANGES" ]] && command -v Rscript &>/dev/null; then
  if [[ -d "$REPO_ROOT/tests/testthat" ]]; then
    echo "[test-on-change] Running R testthat..." >&2
    Rscript -e "testthat::test_dir('tests/testthat')" 2>&1 >&2 || EXIT_CODE=1
  fi
fi

if [[ "$EXIT_CODE" -eq 0 ]]; then
  echo "[test-on-change] ✅ All tests passed." >&2
  echo "[$TIMESTAMP] test-on-change: PASSED" >> "$AUDIT_LOG"
else
  echo "[test-on-change] ❌ Tests failed — fix before proceeding." >&2
  echo "[$TIMESTAMP] test-on-change: FAILED" >> "$AUDIT_LOG"
fi

exit $EXIT_CODE
