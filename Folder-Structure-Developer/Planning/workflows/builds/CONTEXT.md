# Planning/workflows/builds/ — Context

This is **Stage 3** of the agentic build pipeline. See `../CONTEXT.md` for the full overview.

---

## Purpose

Execute the approved spec. All implementation work happens here — writing code, running
tests, resolving blockers. Progress is logged as a running build log so the session can be
resumed at any point.

---

## When to Create a Build Log

After the spec in `specs/` has `Status: APPROVED`. Reference both the brief and spec by
filename at the top of every build log.

---

## Build Log Template

```markdown
# [Project/Feature Name] — Build Log
Date: YYYY-MM-DD
Source Brief: briefs/YYYY-MM-DD_name-brief.md
Source Spec:  specs/YYYY-MM-DD_name-spec.md
Status: IN PROGRESS | COMPLETE

## Task Progress
- [x] Task 1 — completed YYYY-MM-DD
- [/] Task 2 — in progress
- [ ] Task 3

## Decisions Made During Build
Document any deviations from the spec and why.
| Decision | Reason | Impact |
|---|---|---|
| Used X instead of Y | Y had a breaking bug | Spec section 3.2 updated |

## Blockers
- [ ] Blocker: description — assigned to: user/agent

## Files Created / Modified
| File | Action | Notes |
|---|---|---|
| src/services/resultsService.ts | CREATED | Core fetch logic |
| src/components/CountyCard.tsx | CREATED | UI component |

## Testing
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] Manual smoke test complete

## Handoff Notes
What does the next session or reviewer need to know?
```

---

## File Naming

```
YYYY-MM-DD_project-name-build-log.md

Examples:
  2026-04-07_election-map-build-log.md
  2026-04-07_supabase-auth-build-log.md
```

---

## Completion

When all tasks are checked and tests pass:
1. Set `Status: COMPLETE` in the build log header
2. Consult `output-guide/CONTEXT.md` to confirm output was routed correctly into `src/`
3. Files in `src/` are now ready to commit and push
