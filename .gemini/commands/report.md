---
name: report
description: Generate a client-ready status report. Pulls task.md progress, recent git commits, open blockers, and formats a professional deliverable. Use before client syncs, weekly standups, or end-of-sprint reviews.
allowed_tools: ["Read", "Bash", "Write"]
---

# /report

Generates a structured client status report from live project data.

## Step 1 — Gather Project Data

```bash
# Git activity since last report (last 7 days)
git log --oneline --since="7 days ago" --format="- %s (%ad)" --date=short

# Files changed
git diff --stat HEAD~10 HEAD 2>/dev/null | tail -3

# Current branch
git rev-parse --abbrev-ref HEAD
```

Read `task.md` and extract all sections.

## Step 2 — Load Client Context

Check for a `Client-*/Intake/` folder or `Planning/` directory. Read:
- Project name and engagement type
- SOW or brief if present
- Any previous reports in `docs/` or `Client-*/Reports/`

## Step 3 — Generate Report

Write the report to `docs/reports/YYYY-MM-DD_status-report.md` (Developer) or `Client-[Name]/Reports/YYYY-MM-DD_status-report.md` (Consultant):

```markdown
# Status Report — [Project Name]
**Date:** YYYY-MM-DD
**Prepared by:** [Agent / Your Name]
**Period:** [Start] – [End]

---

## Executive Summary
[2–3 sentences: what was delivered, what's next, any risks]

## Completed This Period
| Item | Status | Notes |
|---|---|---|
| [task] | ✅ Done | [brief note] |

## In Progress
| Item | Status | ETA |
|---|---|---|
| [task] | 🔄 Active | [date] |

## Upcoming
| Item | Priority | Dependencies |
|---|---|---|
| [task] | High | [blocker] |

## Blockers & Risks
| Blocker | Impact | Mitigation |
|---|---|---|
| [issue] | [High/Med/Low] | [plan] |

## Key Decisions Made
- [decision and rationale]

## Metrics (if applicable)
- Test coverage: X%
- Open issues: N
- Commits this period: N

---
*Report generated from task.md + git log. Review before sending.*
```

## Step 4 — Review Before Sending

- [ ] All "Completed" items are actually done (verified with tests/demo)
- [ ] No internal notes, PII, or client names in unexpected places
- [ ] Blockers section is honest — no surprises in the meeting
- [ ] Tone is professional, not overly technical for exec audience

## Step 5 — Commit

```bash
git add docs/reports/
git commit -m "docs: add status report $(date +%Y-%m-%d)"
```
