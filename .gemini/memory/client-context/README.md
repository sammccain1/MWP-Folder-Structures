# client-context/

Per-engagement session memory. One file per active client engagement.

## Naming

`[Client-Name]-last-session.md` — e.g., `Barclays-last-session.md`

## Written by

`/sync-memory` at the end of each consultant session.

## Read by

`/standup` at the start of each session when inside a Consultant workspace.

## Format

```markdown
# [Client-Name] — Last Session

**Date:** YYYY-MM-DD
**Branch:** client/name-feature
**Phase:** Intake | Active | Review | Delivery | Archived

## What was done
- [completed task]

## Open tasks
- [ ] [next task]

## Blockers
- [blocker] — owner: [who]

## Key decisions made
- [decision] — rationale: [why]

## Next session starts here
[One sentence: the exact first thing to do next session]
```
