#!/usr/bin/env bash
# MWP session-start hook — prints orientation context at Gemini CLI session boot.
# Runs once on SessionStart. Output goes to stderr (stdout is reserved for JSON).
# This is informational only — never blocks or errors.

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
if [[ -z "$REPO_ROOT" ]]; then exit 0; fi

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")

{
  echo ""
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║              MWP — Session Start                        ║"
  echo "╠══════════════════════════════════════════════════════════╣"
  echo "║  Repo : $REPO_ROOT"
  echo "║  Branch: $BRANCH"
  echo "║  Time  : $TIMESTAMP"
  echo "╠══════════════════════════════════════════════════════════╣"

  # Show task.md status if it exists
  if [[ -f "$REPO_ROOT/task.md" ]]; then
    OPEN=$(grep -c '^\- \[ \]' "$REPO_ROOT/task.md" 2>/dev/null || echo 0)
    IN_PROG=$(grep -c '^\- \[/\]' "$REPO_ROOT/task.md" 2>/dev/null || echo 0)
    DONE=$(grep -c '^\- \[x\]' "$REPO_ROOT/task.md" 2>/dev/null || echo 0)
    echo "║  task.md: $OPEN open · $IN_PROG in-progress · $DONE done"
  fi

  # Last 3 commits
  echo "║"
  echo "║  Recent commits:"
  git log --oneline -3 2>/dev/null | while read -r line; do
    echo "║    $line"
  done

  # Show standing decisions if memory exists
  if [[ -f "$REPO_ROOT/.gemini/memory/standing-decisions.md" ]]; then
    echo "║"
    echo "║  Standing decisions loaded from .gemini/memory/"
  fi

  echo "╚══════════════════════════════════════════════════════════╝"
  echo ""
} >&2

exit 0
