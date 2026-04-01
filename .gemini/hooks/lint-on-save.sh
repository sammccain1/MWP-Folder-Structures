#!/usr/bin/env bash
# MWP lint-on-save hook — run fast linters after file writes.
# STDOUT: JSON only. ALL logging goes to STDERR.
# Fails silently if tools aren't installed — never blocks unrelated work.
set -euo pipefail

CHANGED_FILES="${CHANGED_FILES:-}"
EXIT_CODE=0

lint_python() {
  local file="$1"
  if command -v ruff &>/dev/null; then
    ruff check "$file" --quiet 2>&1 >&2 || EXIT_CODE=1
  fi
}

lint_typescript() {
  local file="$1"
  if command -v tsc &>/dev/null; then
    tsc --noEmit --strict "$file" 2>&1 >&2 || EXIT_CODE=1
  fi
}

lint_shell() {
  local file="$1"
  if command -v shellcheck &>/dev/null; then
    shellcheck "$file" 2>&1 >&2 || EXIT_CODE=1
  fi
}

# Detect changed files from git if not injected by framework
if [[ -z "$CHANGED_FILES" ]]; then
  CHANGED_FILES=$(git diff --name-only 2>/dev/null || echo "")
fi

for file in $CHANGED_FILES; do
  [[ -f "$file" ]] || continue
  case "$file" in
    *.py)        lint_python "$file" ;;
    *.ts|*.tsx)  lint_typescript "$file" ;;
    *.sh)        lint_shell "$file" ;;
  esac
done

AUDIT_LOG="$(git rev-parse --show-toplevel 2>/dev/null)/rules/audit.log"
mkdir -p "$(dirname "$AUDIT_LOG")" 2>/dev/null || true
echo "[$(date +"%Y-%m-%dT%H:%M:%S")] lint-on-save: exit=$EXIT_CODE files=$(echo "$CHANGED_FILES" | wc -w | tr -d ' ')" >> "$AUDIT_LOG"

if [[ "$EXIT_CODE" -eq 0 ]]; then
  echo "[lint-on-save] ✅ Lint passed." >&2
else
  echo "[lint-on-save] ⚠️  Lint errors found — review output above." >&2
fi

exit $EXIT_CODE