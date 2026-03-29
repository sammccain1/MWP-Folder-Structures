---
name: fix-issue
description: Autonomous bug fix workflow. Point at a bug report, error log, or failing test — agent diagnoses and resolves without hand-holding. Follows MWP autonomous bug fixing principle.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /fix-issue

Autonomous bug fix mode. No hand-holding. You are given a bug — you fix it.

## Protocol

**Step 1 — Reproduce**
Do not touch code until you can reproduce the failure deterministically.
```bash
# Python
pytest tests/path/to/test.py::test_name -v

# TypeScript
npm test -- --testNamePattern="failing test name"

# Check logs
tail -100 logs/app.log | grep ERROR
```
If you cannot reproduce: stop and report exactly what you tried.

**Step 2 — Isolate**
Find the smallest failing unit. Use the debugger skill if needed.
- Read the full stack trace — the root cause is rarely on the top line
- Check git log for recent changes to the affected module: `git log --oneline -10 -- path/to/file`
- Diff against main if on a feature branch: `git diff main -- path/to/file`

**Step 3 — Hypothesize**
State your hypothesis before changing any code. Write it in a comment or in your response:
> "I believe the failure is caused by X because Y. My fix will be Z."

**Step 4 — Fix**
Make the smallest change that resolves the root cause.
- No refactoring unrelated code while fixing a bug
- No adding features while fixing a bug
- If the fix requires a broader change, document it and fix only what's needed now

**Step 5 — Verify**
```bash
# Run the originally failing test — must pass
pytest tests/... -v

# Run the full suite — must not regress
pytest / npm test

# If UI-affecting: run E2E for the affected flow
npx playwright test --grep "affected flow"
```

**Step 6 — Commit**
```bash
git add -A
git commit -m "fix: [short description of what was broken and how it's fixed]"
```

Commit message must be specific. Not `fix: bug fix`. Example: `fix: null check on user.email in auth middleware`.

## Common Root Cause Lookup

| Symptom | Check First |
|---|---|
| `TypeError: Cannot read properties of undefined` | Async data not awaited; optional chaining needed |
| `500 Internal Server Error` | FastAPI route missing try/catch; check `uvicorn` logs |
| `CORS error` | Missing origin in FastAPI `CORSMiddleware` config |
| Pandas `KeyError` | Column name mismatch; check `df.columns` after read |
| SQL `relation does not exist` | Migration not applied; run `supabase db push` |
| Flaky test | External dependency (clock, network, random); mock it |
| CI passes locally, fails in CI | Missing env var in CI config; check `.github/workflows/` |

## Notes

- Load `.gemini/agents/skills/debugger/SKILL.md` for extended stack-specific debug patterns
- If the bug is in a critical path (auth, payments, data integrity): fix on a branch, not directly on main
- Never mark fixed without a passing test that would have caught the original bug