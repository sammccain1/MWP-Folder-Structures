---
name: clean
description: Clean up a project workspace — remove build artifacts, caches, temp files, and stale branches. Use at the start of a new sprint or before archiving a project.
allowed_tools: ["Bash", "Read"]
---

# /clean

Workspace hygiene command. Run at the start of a sprint, before archiving, or when things feel cluttered.

## Step 1 — Build Artifacts

```bash
# Next.js / Node
rm -rf .next/ out/ dist/ build/ node_modules/.cache/

# Python
find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true
rm -rf .pytest_cache/ .ruff_cache/ .mypy_cache/

# R
rm -f *.Rhistory .RData
```

## Step 2 — Temp and Scratch Files

```bash
# Remove any /tmp output left in repo
find . -name "*.tmp" -o -name "*.bak" -o -name "preview.mp4" | grep -v node_modules | xargs rm -f 2>/dev/null || true
```

## Step 3 — Stale Git Branches

```bash
# List merged branches ready to delete
git branch --merged main | grep -v "^\*\|main\|develop"

# Delete them (review the list above first!)
git branch --merged main | grep -v "^\*\|main\|develop" | xargs -r git branch -d
```

## Step 4 — Verify Nothing Broken

```bash
git status          # working tree clean?
npm run build 2>&1 | tail -5  # build still passes?
pytest -q 2>&1 | tail -5      # tests still green?
```

## Notes

- Never delete `node_modules/` unless you're ready to `npm install` again — it can take minutes
- Never delete database migration files even if they look stale
- Check `rules/audit.log` is not committed (it's in `.gitignore`)
