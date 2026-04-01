#!/usr/bin/env bash
# MWP secrets-check hook — scan for leaked keys/tokens before any tool use.
# STDOUT: JSON only (Gemini CLI parses this). ALL logging goes to STDERR.
# Exit 2 = hard block. Exit 0 = pass (with optional JSON deny on stdout).
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
if [[ -z "$REPO_ROOT" ]]; then exit 0; fi

cd "$REPO_ROOT"

AUDIT_LOG="$REPO_ROOT/rules/audit.log"
mkdir -p "$(dirname "$AUDIT_LOG")"

FOUND=0

LABELS=(
  "OpenAI API key"
  "Anthropic API key"
  "AWS access key"
  "Google API key"
  "GitHub PAT (classic)"
  "GitHub PAT (fine-grained)"
  "Stripe secret key"
  "Supabase JWT"
  "Generic Bearer token"
)
PATTERNS=(
  'sk-[A-Za-z0-9]{32,}'
  'sk-ant-[A-Za-z0-9-]{32,}'
  'AKIA[0-9A-Z]{16}'
  'AIza[0-9A-Za-z_-]{35}'
  'ghp_[A-Za-z0-9]{36}'
  'github_pat_[A-Za-z0-9_]{82}'
  'sk_live_[A-Za-z0-9]{24,}'
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\.'
  'Bearer [A-Za-z0-9_.~+/=-]{20,}'
)

EXCLUDE_ARGS=(
  --exclude-dir='.git'
  --exclude-dir='node_modules'
  --exclude-dir='__pycache__'
  --exclude='*.lock'
  --exclude='*.png' --exclude='*.jpg' --exclude='*.jpeg'
  --exclude='*.pkl' --exclude='*.parquet'
  --exclude='*.ipynb'
  --exclude='audit.log'
  --exclude='secrets-check.sh'
  --exclude='knowledge.jsonl'
)

echo "[secrets-check] Scanning for leaked secrets..." >&2

for i in "${!LABELS[@]}"; do
  label="${LABELS[$i]}"
  pattern="${PATTERNS[$i]}"
  matches=$(grep -rE "$pattern" "${EXCLUDE_ARGS[@]}" "$REPO_ROOT" 2>/dev/null || true)
  if [[ -n "$matches" ]]; then
    echo "  ⛔  FOUND: $label" >&2
    echo "$matches" | head -5 >&2
    FOUND=1
  fi
done

TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")

if [[ "$FOUND" -eq 1 ]]; then
  echo "[secrets-check] ❌ Secret(s) detected — blocking operation." >&2
  echo "[secrets-check] Fix: remove the value, rotate the key, add it to .env (not the repo)." >&2
  echo "[$TIMESTAMP] secrets-check: BLOCKED — potential secrets found" >> "$AUDIT_LOG"
  # Hard block via exit 2 — Gemini CLI surfaces stderr to the agent
  exit 2
else
  echo "[secrets-check] ✅ No secrets found." >&2
  echo "[$TIMESTAMP] secrets-check: PASSED" >> "$AUDIT_LOG"
  exit 0
fi
