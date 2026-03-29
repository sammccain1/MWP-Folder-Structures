#!/usr/bin/env bash
# MWP test-on-change hook — automatically run relevant tests when src/ files change
# Enforces the test-driven principle without relying on the agent remembering.
# Only runs tests for the languages actually present in the changed files.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"

if [[ -z "$REPO_ROOT" ]]; then
  echo "[test-on-change] Not inside a git repo — skipping." >&2
  exit 0
fi

cd "$REPO_ROOT"

AUDIT_LOG="$REPO_ROOT/rules/audit.log"
mkdir -p "$(dirname "$AUDIT_LOG")"
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")

# ────────────────────────────────────────────────────────────────────────────
# Detect changed files (staged + unstaged, relative to HEAD)
# ────────────────────────────────────────────────────────────────────────────
CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || git diff --name-only 2>/dev/null || echo "")

if [[ -z "$CHANGED_FILES" ]]; then
  echo "[test-on-change] No changed files detected — skipping."
  exit 0
fi

# Only react to src/ changes — skip docs, ops, data, etc.
SRC_CHANGES=$(echo "$CHANGED_FILES" | grep -E '^(src|Folder-Structure-.*)' | grep -E '\.(py|ts|tsx|r|R|js|jsx)$' || true)

if [[ -z "$SRC_CHANGES" ]]; then
  echo "[test-on-change] No src/ changes detected — skipping tests."
  exit 0
fi

echo "[test-on-change] src/ changes detected:"
echo "$SRC_CHANGES"
echo ""

EXIT_CODE=0

# ────────────────────────────────────────────────────────────────────────────
# Python — pytest
# ────────────────────────────────────────────────────────────────────────────
PY_CHANGES=$(echo "$SRC_CHANGES" | grep '\.py$' || true)
if [[ -n "$PY_CHANGES" ]] && command -v pytest &>/dev/null; then
  echo "[test-on-change] Running pytest..."
  if [[ -d "$REPO_ROOT/src/tests" ]]; then
    pytest "$REPO_ROOT/src/tests" -q --tb=short 2>&1 || EXIT_CODE=1
  elif [[ -d "$REPO_ROOT/tests" ]]; then
    pytest "$REPO_ROOT/tests" -q --tb=short 2>&1 || EXIT_CODE=1
  else
    echo "[test-on-change] No tests/ directory found — skipping pytest."
  fi
fi

# ────────────────────────────────────────────────────────────────────────────
# TypeScript/JavaScript — npm test (if package.json present)
# ────────────────────────────────────────────────────────────────────────────
TS_CHANGES=$(echo "$SRC_CHANGES" | grep -E '\.(ts|tsx|js|jsx)$' || true)
if [[ -n "$TS_CHANGES" ]] && [[ -f "$REPO_ROOT/package.json" ]]; then
  echo "[test-on-change] Running npm test..."
  npm test --silent 2>&1 || EXIT_CODE=1
fi

# ────────────────────────────────────────────────────────────────────────────
# R — testthat (if tests/testthat present)
# ────────────────────────────────────────────────────────────────────────────
R_CHANGES=$(echo "$SRC_CHANGES" | grep -E '\.(r|R)$' || true)
if [[ -n "$R_CHANGES" ]] && command -v Rscript &>/dev/null; then
  if [[ -d "$REPO_ROOT/tests/testthat" ]]; then
    echo "[test-on-change] Running R testthat..."
    Rscript -e "testthat::test_dir('tests/testthat')" 2>&1 || EXIT_CODE=1
  fi
fi

# ────────────────────────────────────────────────────────────────────────────
# Audit log
# ────────────────────────────────────────────────────────────────────────────
if [[ "$EXIT_CODE" -eq 0 ]]; then
  echo ""
  echo "[test-on-change] ✅ All tests passed."
  echo "[$TIMESTAMP] test-on-change: PASSED changed=$(echo "$SRC_CHANGES" | wc -l | tr -d ' ') files" >> "$AUDIT_LOG"
else
  echo ""
  echo "[test-on-change] ❌ One or more tests failed. Fix before proceeding."
  echo "[$TIMESTAMP] test-on-change: FAILED" >> "$AUDIT_LOG"
fi

exit $EXIT_CODE
