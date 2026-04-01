---
name: debug
description: Structured debugging session. Loads the debugger skill, reproduces the failure in isolation, bisects the cause, proposes a fix, and verifies with tests. Use when given a bug report, failing test, or unexpected behavior.
allowed_tools: ["Read", "Write", "Bash"]
---

# /debug

Autonomous bug fix workflow. No hand-holding needed — follow this to find and fix the issue.

> Load `.gemini/Skills/debugger/SKILL.md` before starting.

## Step 1 — Reproduce First

Do not guess at fixes. Reproduce the bug with a minimal, deterministic case.

```bash
# Run the failing test in isolation
pytest tests/test_[module].py::test_[failing_case] -xvs 2>&1 | head -50

# Or for TypeScript
npm test -- --testPathPattern="[failing_spec]" --verbose

# Or trigger the error manually
curl -X POST http://localhost:8000/api/[endpoint] \
  -H "Content-Type: application/json" \
  -d '{"payload": "that_triggers_bug"}'
```

**Required before moving on:** you can reproduce it on demand.

## Step 2 — Read the Stack Trace

Parse the full error output:
- What is the exact error message?
- Which file and line number does it point to?
- What is the call stack? Read it bottom-up (root cause is usually near the bottom).

```bash
# Get full traceback without truncation
pytest tests/test_[module].py -xvs --tb=long 2>&1
```

## Step 3 — Bisect the Cause

Identify the smallest change that introduced the bug:

```bash
# Find when it broke
git bisect start
git bisect bad HEAD
git bisect good [last-known-good-commit]
# Run your reproduction command after each step
git bisect run pytest tests/test_[module].py -x -q
git bisect reset
```

If bisect isn't practical, narrow by:
1. Adding `print` / `console.log` at boundaries to trace data flow
2. Checking recent changes to the affected file: `git log --oneline -10 -- [file]`
3. Reading the test's setup and teardown for hidden state

## Step 4 — Hypothesize and Verify

List the top 2–3 root cause hypotheses. For each:
- What would the code need to look like for this hypothesis to be true?
- Can you verify it with a targeted print or assertion?

Do not touch production code until you have confirmed the root cause.

## Step 5 — Fix

Apply the minimal fix:
- **Fix the root cause, not the symptom**
- No `try/except Exception: pass` patches — handle specifically
- If the fix requires a refactor, scope it narrowly or open a follow-up task

```bash
# After editing, verify the fix didn't break anything else
pytest --tb=short -q       # Python
npm test -- --passWithNoTests  # TypeScript
```

## Step 6 — Write a Regression Test

Add a test that would have caught this bug:

```python
def test_[bug_description]_regression():
    """Regression test for [issue]. Previously caused [error]."""
    # Arrange: exact conditions that triggered the bug
    # Act: call the code that was broken
    # Assert: confirm the bug is gone
```

## Step 7 — Commit

```bash
git add .
git commit -m "fix([scope]): [concise description of what was wrong and fix]

Fixes: [error message or issue reference]
Root cause: [one sentence]
Regression test: [test name]"
```

## Common Patterns

| Symptom | Likely Cause | Starting Point |
|---|---|---|
| `KeyError` / `AttributeError` | Null/missing data assumed present | Check input validation |
| Test passes locally, fails in CI | Env vars, ordering, file paths | Check CI env, `conftest.py` |
| Intermittent failure | Race condition or time-dependent | Add sleep, check async handling |
| Works for one user, not another | Missing RLS or permission check | Check auth context in tests |
| API 422 / validation error | Schema mismatch between client and server | Diff request payload vs Pydantic model |
| DB query returns wrong data | Missing `WHERE` clause or wrong join | Run query directly in psql |
