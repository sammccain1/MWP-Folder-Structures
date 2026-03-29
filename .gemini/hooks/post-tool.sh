#!/usr/bin/env bash
# MWP post-tool hook — audit log entry after every agent tool call
# Closes the loop opened by pre-commit.sh; records what the agent did and its exit status.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"

if [[ -z "$REPO_ROOT" ]]; then
  echo "[post-tool] Not inside a git repo — skipping." >&2
  exit 0
fi

AUDIT_LOG="$REPO_ROOT/rules/audit.log"
mkdir -p "$(dirname "$AUDIT_LOG")"

# ────────────────────────────────────────────────────────────────────────────
# Context — passed by the agent framework as environment variables (if supported)
# Fall back to sensible defaults when running standalone.
# ────────────────────────────────────────────────────────────────────────────
TOOL_NAME="${TOOL_NAME:-unknown-tool}"
TOOL_EXIT="${TOOL_EXIT:-0}"
TOOL_ARGS="${TOOL_ARGS:-}"       # truncated summary of args, not full payload
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")

# ────────────────────────────────────────────────────────────────────────────
# Write audit entry
# ────────────────────────────────────────────────────────────────────────────
LOG_LINE="[$TIMESTAMP] post-tool: tool=$TOOL_NAME exit=$TOOL_EXIT branch=$BRANCH"
if [[ -n "$TOOL_ARGS" ]]; then
  # Truncate to 120 chars to keep log readable
  TOOL_ARGS_SHORT="${TOOL_ARGS:0:120}"
  LOG_LINE="$LOG_LINE args=\"$TOOL_ARGS_SHORT\""
fi

echo "$LOG_LINE" >> "$AUDIT_LOG"

# ────────────────────────────────────────────────────────────────────────────
# Alert on tool failure — non-zero exit warrants extra log visibility
# ────────────────────────────────────────────────────────────────────────────
if [[ "$TOOL_EXIT" != "0" ]]; then
  echo "[post-tool] ⚠️  Tool '$TOOL_NAME' exited with code $TOOL_EXIT — logged to audit.log"
  echo "[$TIMESTAMP] post-tool: WARNING tool=$TOOL_NAME failed with exit=$TOOL_EXIT" >> "$AUDIT_LOG"
fi

echo "[post-tool] Audited: $TOOL_NAME (exit=$TOOL_EXIT)"
exit 0
