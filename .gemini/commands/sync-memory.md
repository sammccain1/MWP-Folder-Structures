---
name: sync-memory
description: End-of-session memory sync. Writes key decisions, open tasks, and blockers to standing-decisions.md, the MCP knowledge graph, and (for Consultant sessions) a per-client last-session file in .gemini/memory/client-context/. Run before ending any session so /standup can reconstruct full context next time.
allowed_tools: ["Read", "Write", "Bash"]
---

# /sync-memory

End-of-session command. Run this before closing any session. Captures state so the next session starts oriented, not blind.

---

## Step 1 — Detect Workspace

```bash
# Determine if this is a Consultant or Developer session
WORKSPACE="developer"
if [[ -d "Client-"* ]] || grep -q "Kubrick\|consultant" CLAUDE.md 2>/dev/null; then
  WORKSPACE="consultant"
fi
echo "Workspace: $WORKSPACE"

# Identify active client (Consultant only)
CLIENT_NAME=""
if [[ "$WORKSPACE" == "consultant" ]]; then
  CLIENT_NAME=$(ls -d Client-*/  2>/dev/null | grep -v "Alpha\|Beta" | head -1 | tr -d '/' || echo "")
  echo "Active client: ${CLIENT_NAME:-none}"
fi
```

---

## Step 2 — Summarize Task Progress

```bash
# Read task.md
TASK_FILE=$(find . -maxdepth 2 -name "task.md" | head -1)
if [[ -n "$TASK_FILE" ]]; then
  OPEN=$(grep -c '^\- \[ \]' "$TASK_FILE" 2>/dev/null || echo 0)
  IN_PROG=$(grep -c '^\- \[/\]' "$TASK_FILE" 2>/dev/null || echo 0)
  DONE=$(grep -c '^\- \[x\]' "$TASK_FILE" 2>/dev/null || echo 0)
  echo "Tasks — open: $OPEN | in-progress: $IN_PROG | done: $DONE"
fi
```

Compose a summary covering:
- What was accomplished this session (3–5 bullets)
- What is still open or in-progress
- Any blockers encountered
- The single most important thing to do at the start of next session

---

## Step 3 — Write Per-Client Session File (Consultant only)

If `WORKSPACE == "consultant"` and `CLIENT_NAME` is set, write to:

`.gemini/memory/client-context/[CLIENT_NAME]-last-session.md`

```markdown
# [CLIENT_NAME] — Last Session

**Date:** YYYY-MM-DD
**Branch:** [git rev-parse --abbrev-ref HEAD]
**Phase:** Intake | Active Development | Review | Delivery | Archived

## What was done
- [completed task]
- [completed task]

## Open tasks
- [ ] [next task — be specific enough to act on immediately]

## Blockers
- [blocker] — owner: [who resolves it]

## Key decisions made
- [decision] — rationale: [why]

## Next session starts here
[One sentence: the exact first action to take next session, e.g. "Run the migration against staging and verify RLS policies."]
```

Create the file if it doesn't exist. Overwrite if it does — this is a rolling last-session record, not a log.

---

## Step 4 — Update standing-decisions.md

Only append if a genuine architectural or cross-project decision was made this session. Not every session warrants an entry.

```bash
DECISIONS_FILE=".gemini/memory/standing-decisions.md"
```

Append to `.gemini/memory/standing-decisions.md`:

```markdown

---
## [YYYY-MM-DD] — [Short title of decision]

**Decision:** [What was decided]
**Rationale:** [Why — what alternatives were considered]
**Applies to:** Developer | Consultant | Both
```

Skip this step entirely if no new cross-project decisions were made.

---

## Step 5 — Write to Knowledge Graph

Using the MCP `knowledge-graph` server, upsert a session entity:

```
create_entity:
  name: session-YYYY-MM-DD
  type: Session
  observations:
    - "Workspace: [developer|consultant]"
    - "Client: [name or n/a]"
    - "Completed: [bullet]"
    - "Open: [bullet]"
    - "Next: [first action next session]"
```

If a client entity doesn't exist yet, create one:

```
create_entity:
  name: client-[CLIENT_NAME]
  type: ConsultantEngagement
  observations:
    - "Phase: [current phase]"
    - "Last session: YYYY-MM-DD"
    - "Key contact: [name if known]"
```

---

## Step 6 — Git Checkpoint

```bash
git add -A
git status  # review before committing
git commit -m "chore: end-of-session sync [$(date +%Y-%m-%d)]"
```

---

## Step 7 — Confirm

Print a summary:

```
Memory synced on [date]:
  ✅ task.md: [N open | N in-progress | N done]
  ✅ client-context/[CLIENT_NAME]-last-session.md written   (consultant only)
  ✅ standing-decisions.md: [appended | no new decisions]
  ✅ knowledge graph: session-[date] upserted
  ✅ git: [commit hash]

Next session: run /standup to restore context.
```
