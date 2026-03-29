#!/usr/bin/env bash
# MWP pre-commit hook — git snapshot before any destructive tool use
# Enforces: commit before act. If working tree is dirty, auto-snapshot it.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"

if [[ -z "$REPO_ROOT" ]]; then
  echo "[pre-commit] Not inside a git repo — skipping snapshot." >&2
  exit 0
fi

cd "$REPO_ROOT"

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
  TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

  echo "[pre-commit] Dirty working tree detected on branch: $BRANCH"
  echo "[pre-commit] Auto-snapshotting before agent acts..."

  git add -A
  git commit -m "chore: pre-act snapshot [$TIMESTAMP] on $BRANCH" --no-verify

  echo "[pre-commit] Snapshot committed. Agent may now proceed."
else
  echo "[pre-commit] Working tree clean — no snapshot needed."
fi

# Append to audit log
AUDIT_LOG="$REPO_ROOT/rules/audit.log"
mkdir -p "$(dirname "$AUDIT_LOG")"
echo "[$(date +"%Y-%m-%dT%H:%M:%S")] pre-commit hook ran on branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null)" >> "$AUDIT_LOG"