#!/usr/bin/env bash
# MWP pre-commit hook — git snapshot before any shell command tool use.
# STDOUT: JSON only. ALL logging goes to STDERR.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
if [[ -z "$REPO_ROOT" ]]; then exit 0; fi

cd "$REPO_ROOT"

AUDIT_LOG="$REPO_ROOT/rules/audit.log"
mkdir -p "$(dirname "$AUDIT_LOG")"

if ! git diff --quiet || ! git diff --cached --quiet; then
  TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

  echo "[pre-commit] Dirty working tree on '$BRANCH' — auto-snapshotting..." >&2

  git add -A
  git commit -m "chore: pre-act snapshot [$TIMESTAMP] on $BRANCH" --no-verify >&2

  echo "[pre-commit] Snapshot committed. Proceeding." >&2
else
  echo "[pre-commit] Working tree clean — no snapshot needed." >&2
fi

echo "[$(date +"%Y-%m-%dT%H:%M:%S")] pre-commit: ran on $(git rev-parse --abbrev-ref HEAD 2>/dev/null)" >> "$AUDIT_LOG"
exit 0