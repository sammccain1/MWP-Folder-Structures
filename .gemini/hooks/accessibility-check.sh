#!/usr/bin/env bash
# MWP accessibility-check hook — run axe-core or pa11y against a local dev server
# Triggers PostToolUse when UI component files change.
# Fails silently if no dev server is running to avoid blocking non-UI work.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
if [[ -z "$REPO_ROOT" ]]; then exit 0; fi

AUDIT_LOG="$REPO_ROOT/rules/audit.log"
mkdir -p "$(dirname "$AUDIT_LOG")"
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")

# Only run if a Next.js or similar frontend project is present
if [[ ! -f "$REPO_ROOT/package.json" ]]; then
  echo "[a11y-check] No package.json found — skipping."
  exit 0
fi

# Only trigger on UI-related file changes
CHANGED_FILES="${CHANGED_FILES:-$(git diff --name-only HEAD 2>/dev/null || echo "")}"
UI_CHANGES=$(echo "$CHANGED_FILES" | grep -E '\.(tsx|jsx|html|css)$' || true)

if [[ -z "$UI_CHANGES" ]]; then
  echo "[a11y-check] No UI file changes — skipping."
  exit 0
fi

echo "[a11y-check] UI files changed, running accessibility check..."

DEV_URL="${DEV_URL:-http://localhost:3000}"
EXIT_CODE=0

# Check if dev server is running
if ! curl -s --max-time 2 "$DEV_URL" > /dev/null; then
  echo "[a11y-check] Dev server not running at $DEV_URL — skipping live check."
  echo "  Tip: Run 'npm run dev' before making UI changes for live a11y feedback."
  echo "[$TIMESTAMP] a11y-check: SKIPPED (no dev server)" >> "$AUDIT_LOG"
  exit 0
fi

# ── pa11y (preferred — no browser required) ───────────────────────────────
if command -v pa11y &>/dev/null; then
  echo "[a11y-check] Running pa11y on $DEV_URL..."
  # WCAG2AA is the client-grade standard
  RESULT=$(pa11y "$DEV_URL" --standard WCAG2AA --reporter cli 2>&1 || true)
  ERROR_COUNT=$(echo "$RESULT" | grep -c "error" || true)

  if [[ "$ERROR_COUNT" -gt 0 ]]; then
    echo "[a11y-check] ⚠️  $ERROR_COUNT WCAG2AA violations found:"
    echo "$RESULT" | grep "error" | head -10
    EXIT_CODE=1
  else
    echo "[a11y-check] ✅ No WCAG2AA errors found."
  fi

# ── axe-cli (fallback) ────────────────────────────────────────────────────
elif command -v axe &>/dev/null; then
  echo "[a11y-check] Running axe on $DEV_URL..."
  axe "$DEV_URL" 2>&1 || EXIT_CODE=1

else
  echo "[a11y-check] Neither pa11y nor axe-cli installed."
  echo "  Install: npm install -g pa11y"
  echo "[$TIMESTAMP] a11y-check: SKIPPED (no tools)" >> "$AUDIT_LOG"
  exit 0
fi

if [[ "$EXIT_CODE" -eq 0 ]]; then
  echo "[$TIMESTAMP] a11y-check: PASSED" >> "$AUDIT_LOG"
else
  echo "[$TIMESTAMP] a11y-check: FAILED violations=$ERROR_COUNT" >> "$AUDIT_LOG"
fi

exit $EXIT_CODE
