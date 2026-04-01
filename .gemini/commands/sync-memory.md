---
name: sync-memory
description: End-of-session memory sync. Writes key decisions, open tasks, blockers, and architectural context to .gemini/memory/standing-decisions.md and the MCP knowledge graph. Run before ending any session so /standup can reconstruct context next time.
allowed_tools: ["Read", "Write", "Bash"]
---

# /sync-memory

End-of-session command. Captures state so the next session picks up exactly where this one left off.

## Step 1 — Summarize Task Progress

Read `task.md` and extract:

```bash
# Count task states
grep -c '^\- \[ \]' task.md 2>/dev/null && echo "open"
grep -c '^\- \[/\]' task.md 2>/dev/null && echo "in-progress"
grep -c '^\- \[x\]' task.md 2>/dev/null && echo "done"
```

Compose a 3–5 sentence summary of:
- What was accomplished this session
- What is still open
- Any blockers encountered

## Step 2 — Update standing-decisions.md

Append a new dated entry to `.gemini/memory/standing-decisions.md`:

```markdown
## Session: YYYY-MM-DD

### Completed
- [bullet per completed item]

### Open
- [bullet per open or in-progress item]

### Decisions Made
- [any architectural or design decisions locked in]

### Blockers / Notes
- [anything the next session needs to know]
```

## Step 3 — Write to Knowledge Graph

Using the MCP `knowledge-graph` server, create or update an entity for this session:

- Entity type: `Session`
- Entity name: `session-YYYY-MM-DD`
- Observations: decisions made, key file paths touched, open work

Example entity structure:
```
create_entity:
  name: session-2026-03-31
  type: Session
  observations:
    - "Added web-animation skill with 7 sub-skills"
    - "Fixed settings.json hook schema to BeforeTool/AfterTool"
    - "Open: demo-prep command not yet built"
```

## Step 4 — Git Checkpoint

```bash
git add -A
git status  # review what's staged
git commit -m "chore: end-of-session checkpoint [$(date +%Y-%m-%d)]"
```

## Step 5 — Confirm

Print a summary of what was written:
- Lines added to `standing-decisions.md`
- Knowledge graph entities created/updated
- Commit hash

Memory is synced. This session's context is durable.
