---
name: standup
description: Session-start briefing. Reads task.md, recent git log, and open issues to orient the agent at the start of every working session. Run this first, every time.
allowed_tools: ["Bash", "Read", "Grep", "Glob"]
---

# /standup

Run this command at the **start of every session** before touching any code. It answers three questions:
1. Where did we leave off?
2. What is blocked or at risk?
3. What is the plan for this session?

---

## Step 1 — Read task.md

Find and display the current `task.md`:

```bash
find . -maxdepth 2 -name "task.md" | head -3
```

Then read it. Summarise:
- All `[/]` (in-progress) items — these are your immediate focus
- All `[ ]` (uncompleted) items — these are the backlog
- All `[x]` (completed) items — skip unless there is a regression

---

## Step 2 — Scan recent git history

```bash
git log --oneline -10
```

Note:
- Last commit message and timestamp
- Whether a snapshot (`chore: pre-act snapshot`) is the most recent commit (= agent was mid-task when session ended)
- Any branches other than `main` currently active

---

## Step 3 — Check for failing tests

```bash
# Python
pytest src/tests/ -q --tb=line 2>&1 | tail -20 || true

# Node
npm test --silent 2>&1 | tail -20 || true
```

If tests are failing: **stop**. Fix tests before picking up new work. Update `task.md` to reflect this.

---

## Step 4 — Check rules/lessons.md

```bash
cat rules/lessons.md
```

Review the last 3 lessons to avoid repeating recent mistakes.

---

## Step 5 — Produce the Standup Summary

Output a concise block in this format:

```
## Standup — [date]

**Last session ended:** [last commit message + timestamp]
**Branch:** [current branch]

**In-progress:**
- [task] → [next action]

**Blocked:**
- [item] — reason

**Session goal:**
- [top 1-2 tasks for this session]

**Test status:** ✅ passing / ❌ N failures (listed below)
```

---

## Notes

- This command is read-only. It does not write files or commit anything.
- If `task.md` doesn't exist, create it using the template from `GEMINI.md` before proceeding.
- If the branch is not `main`, confirm this is intentional before starting feature work.
