---
name: standup
description: Session-start briefing. Detects workspace (Developer vs Consultant), reads task.md, per-client last-session memory, recent git log, and lessons.md to orient the agent before any work begins. Run this first, every time.
allowed_tools: ["Bash", "Read", "Grep", "Glob"]
---

# /standup

Run at the **start of every session** before touching any code or files. Read-only — does not write or commit anything.

Answers three questions:
1. Where did we leave off?
2. What is blocked or at risk?
3. What is the plan for this session?

---

## Step 1 — Detect Workspace

```bash
# Identify whether this is a Developer or Consultant session
if ls Client-*/ &>/dev/null 2>&1 || grep -q "Kubrick\|consultant" CLAUDE.md 2>/dev/null; then
  echo "Workspace: CONSULTANT"
  WORKSPACE="consultant"
  # Find active client (non-placeholder)
  CLIENT_NAME=$(ls -d Client-*/  2>/dev/null | grep -v "Alpha\|Beta" | head -1 | tr -d '/' || echo "")
  echo "Active client: ${CLIENT_NAME:-none detected}"
else
  echo "Workspace: DEVELOPER"
  WORKSPACE="developer"
  CLIENT_NAME=""
fi
```

---

## Step 2 — Load Per-Client Memory (Consultant only)

If `WORKSPACE == "consultant"` and `CLIENT_NAME` is set, read:

```bash
LAST_SESSION=".gemini/memory/client-context/${CLIENT_NAME}-last-session.md"
if [[ -f "$LAST_SESSION" ]]; then
  cat "$LAST_SESSION"
else
  echo "No last-session file found for $CLIENT_NAME."
  echo "This may be the first session for this client — read their CONTEXT.md."
  cat "Client-${CLIENT_NAME}/CONTEXT.md" 2>/dev/null || true
fi
```

Extract and surface:
- **"Next session starts here"** line — this is your first action
- Open tasks from the last session
- Any blockers that were logged

---

## Step 3 — Read task.md

```bash
TASK_FILE=$(find . -maxdepth 2 -name "task.md" | head -1)
if [[ -n "$TASK_FILE" ]]; then
  cat "$TASK_FILE"
else
  echo "No task.md found. Create one before starting work."
fi
```

Summarise:
- `[/]` in-progress items — **immediate focus**
- `[ ]` open items — backlog
- `[x]` done items — skip unless there is a regression concern

---

## Step 4 — Scan Recent Git History

```bash
git log --oneline -10
git status --short
git branch
```

Note:
- Last commit message and author timestamp
- If the most recent commit is a `chore: pre-act snapshot` — the agent was mid-task when the session ended, resume from that state
- If on a non-`main` branch, confirm it's intentional before starting feature work
- Any uncommitted changes — surface them explicitly

---

## Step 5 — Check Test Status

```bash
# Python
pytest src/tests/ -q --tb=line 2>&1 | tail -15 || true

# Node / TypeScript
npm test --silent 2>&1 | tail -15 || true

# R
Rscript -e "testthat::test_dir('tests/testthat')" 2>&1 | tail -10 || true
```

If any tests are failing: **stop**. Fix failures before picking up new work. Add a `[/]` item to `task.md` for the failing test.

---

## Step 6 — Read Standing Decisions

```bash
cat .gemini/memory/standing-decisions.md 2>/dev/null | tail -40
```

Surface any decisions relevant to the current task — especially:
- LOSO CV for ML/sports work
- Parquet-over-CSV for pipeline interop
- No placeholders in frontend
- Forward-only migration strategy

---

## Step 7 — Read lessons.md

```bash
cat rules/lessons.md 2>/dev/null | tail -30
```

Review the most recent lessons. Flag any that are directly relevant to today's planned work.

---

## Step 8 — Produce Standup Summary

Output this block before doing anything else:

```
## Standup — [YYYY-MM-DD]

**Workspace:** Developer | Consultant — [Client-Name]
**Branch:** [branch]
**Last session:** [last commit message + date]

**Resuming from:**
[The "Next session starts here" line from last-session file, or last in-progress task]

**In-progress:**
- [task] → [exact next action]

**Open (backlog):**
- [task]

**Blocked:**
- [item] — [reason] — [who unblocks it]

**Test status:** ✅ all passing | ❌ [N] failures — fix first

**Relevant lessons:**
- [lesson applicable to today's work]

**Session goal:**
[1–2 tasks that would make this session a success]
```

---

## Notes

- This command is **read-only** — no writes, no commits
- If `task.md` doesn't exist: create it from the workspace template before starting
- If no `last-session` file exists for a consultant client: read their `CONTEXT.md` and `Intake/` directory instead
- If standing-decisions.md references an applicable rule, surface it explicitly — don't assume it's been remembered
