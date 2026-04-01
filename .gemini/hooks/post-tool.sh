#!/usr/bin/env bash
# MWP post-tool hook — structured audit log entry after every tool call.
# STDOUT: JSON only. ALL logging goes to STDERR.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
if [[ -z "$REPO_ROOT" ]]; then exit 0; fi

AUDIT_LOG="$REPO_ROOT/rules/audit.log"
mkdir -p "$(dirname "$AUDIT_LOG")"

# Gemini CLI passes tool context via stdin as JSON
TOOL_NAME="unknown-tool"
TOOL_EXIT="0"
if read -t 1 -r stdin_data 2>/dev/null; then
  TOOL_NAME=$(echo "$stdin_data" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool','unknown-tool'))" 2>/dev/null || echo "unknown-tool")
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")

LOG_LINE="[$TIMESTAMP] post-tool: tool=$TOOL_NAME branch=$BRANCH"
echo "$LOG_LINE" >> "$AUDIT_LOG"

echo "[post-tool] Audited: $TOOL_NAME on $BRANCH" >&2
exit 0
