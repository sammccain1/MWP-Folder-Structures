#!/usr/bin/env bash
# MWP lint-on-save hook — runs fast linters on changed files before save
# Fails silently on missing tools (don't block agent if environment isn't set up)
set -euo pipefail

CHANGED_FILES="${CHANGED_FILES:-}"
EXIT_CODE=0

lint_python() {
  local file="$1"
  if command -v ruff &>/dev/null; then
    ruff check "$file" --quiet || EXIT_CODE=1
  fi
}

lint_typescript() {
  local file="$1"
  if command -v tsc &>/dev/null; then
    tsc --noEmit --strict "$file" 2>/dev/null || EXIT_CODE=1
  fi
}

lint_shell() {
  local file="$1"
  if command -v shellcheck &>/dev/null; then
    shellcheck "$file" || EXIT_CODE=1
  fi
}

# If CHANGED_FILES not set, detect from git
if [[ -z "$CHANGED_FILES" ]]; then
  CHANGED_FILES=$(git diff --name-only 2>/dev/null || echo "")
fi

for file in $CHANGED_FILES; do
  [[ -f "$file" ]] || continue
  case "$file" in
    *.py)           lint_python "$file" ;;
    *.ts|*.tsx)     lint_typescript "$file" ;;
    *.sh)           lint_shell "$file" ;;
  esac
done

# Log result
AUDIT_LOG="$(git rev-parse --show-toplevel 2>/dev/null)/rules/audit.log"
if [[ -f "$(dirname "$AUDIT_LOG")" ]] || mkdir -p "$(dirname "$AUDIT_LOG")" 2>/dev/null; then
  echo "[$(date +"%Y-%m-%dT%H:%M:%S")] lint-on-save: exit=$EXIT_CODE files=$(echo "$CHANGED_FILES" | wc -w | tr -d ' ')" >> "$AUDIT_LOG"
fi

exit $EXIT_CODE