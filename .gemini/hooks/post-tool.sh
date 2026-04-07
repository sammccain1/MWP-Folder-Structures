#!/usr/bin/env bash
# MWP post-tool hook — structured audit log entry after every tool call.
# STDOUT: JSON only. ALL logging goes to STDERR.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
if [[ -z "$REPO_ROOT" ]]; then exit 0; fi

AUDIT_LOG="$REPO_ROOT/rules/audit.log"
mkdir -p "$(dirname "$AUDIT_LOG")"

# Gemini CLI passes tool context via environment variables, not stdin.
# GEMINI_TOOL_NAME is the canonical var; fall back to TOOL_NAME, then 'unknown'.
TOOL_NAME="${GEMINI_TOOL_NAME:-${TOOL_NAME:-unknown-tool}}"

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")

LOG_LINE="[$TIMESTAMP] post-tool: tool=$TOOL_NAME branch=$BRANCH"
echo "$LOG_LINE" >> "$AUDIT_LOG"

echo "[post-tool] Audited: $TOOL_NAME on $BRANCH" >&2
exit 0
