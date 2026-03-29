---
name: checkpoint
description: Mid-session save. Commits current state, updates task.md with progress, appends to audit.log, and summarises what's done and what's next. Use any time you want to preserve state before a risky operation, or before ending a session early.
allowed_tools: ["Bash", "Read", "Write"]
---

# /checkpoint

Use this command to **save state mid-session**. It is safe to run at any time. Useful before:
- Risky refactors or schema changes
- Stepping away mid-task
- Handing off to another agent
- Any operation that could lose work

---

## Step 1 — Update task.md

Before committing, update `task.md`:
- Mark any just-completed items as `[x]`
- Mark anything currently in-flight as `[/]`
- Add any new tasks discovered during the session as `[ ]`

If `task.md` doesn't exist, create it now — do not skip this step.

---

## Step 2 — Run secrets check

```bash
# Quick scan for accidental secrets before committing
.gemini/hooks/secrets-check.sh
```

If secrets are found: **stop**. Remove the secret, then re-run before continuing.

---

## Step 3 — Stage and commit

```bash
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

git add -A
git commit -m "chore: checkpoint [$TIMESTAMP] on $BRANCH"
```

If there is nothing to commit (clean tree), skip this step and note it in the summary.

---

## Step 4 — Append to audit log

```bash
AUDIT_LOG="$(git rev-parse --show-toplevel)/rules/audit.log"
mkdir -p "$(dirname "$AUDIT_LOG")"
echo "[$(date +"%Y-%m-%dT%H:%M:%S")] checkpoint: saved on branch=$(git rev-parse --abbrev-ref HEAD)" >> "$AUDIT_LOG"
```

---

## Step 5 — Output checkpoint summary

Produce a summary in this format:

```
## Checkpoint — [timestamp]

**Branch:** [branch]
**Commit:** [git short SHA]

**Completed this session:**
- [x] [item]

**Still in progress:**
- [/] [item] — [next action]

**Remaining:**
- [ ] [item]

**Notes:**
[Anything the next agent/session should know]
```

---

## Notes

- This command never pushes to remote — it only commits locally
- Run `/standup` at the start of the next session to resume from where this left off
- If you are about to run a destructive command (drop table, delete files, etc.), always checkpoint first
- Checkpoint commits use `--no-verify` is intentionally NOT set — hooks should still run
