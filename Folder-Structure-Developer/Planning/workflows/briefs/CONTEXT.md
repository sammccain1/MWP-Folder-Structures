# Planning/workflows/briefs/ — Context

This is **Stage 1** of the agentic build pipeline. See `../CONTEXT.md` for the full overview.

---

## Purpose

Capture **what** the user wants to build — in plain language, before any technical decisions
are made. A brief is the single source of truth that drives the spec in Stage 2.

---

## When to Create a Brief

Any time a user says something like:
- "I want to build X"
- "Add a feature that does Y"
- "Create a new Z"

**Do not start writing specs or code until a brief exists and is confirmed.**

---

## Brief Template

```markdown
# [Project/Feature Name] — Brief
Date: YYYY-MM-DD
Author: [user or agent]

## What to Build
One paragraph. Plain language. What is this thing?

## Why
The problem it solves or the value it delivers.

## Key Features
- Feature 1
- Feature 2
- Feature 3

## Constraints
- Tech constraints (must use X, cannot use Y)
- Time constraints
- Scope limits ("not building auth in this pass")

## Success Criteria
How will we know it's done and working?

## Out of Scope
Explicitly list what this brief does NOT cover.
```

---

## File Naming

```
YYYY-MM-DD_project-name-brief.md

Examples:
  2026-04-07_election-map-brief.md
  2026-04-07_supabase-auth-brief.md
```

---

## Handoff

Once the brief is written and confirmed by the user → move to `specs/` for Stage 2.
Link the spec back to this brief file by filename.
