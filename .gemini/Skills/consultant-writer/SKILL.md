---
name: consultant-writer
description: Consulting document writing patterns for Sam's Kubrick engagements. Load when drafting SOWs, proposals, status reports, or executive summaries. Provides document templates, tone guidelines, and structure conventions for professional client-facing deliverables.
---

# Consultant Writer Skill

Document templates and tone guidelines for Kubrick-context consulting deliverables. Every document in this skill is designed to be client-ready with minimal revision.

---

## Tone Guidelines

| Context | Tone | Avoid |
|---|---|---|
| SOW / Proposal | Precise, formal, outcome-focused | Jargon, hedging, passive voice |
| Status Update | Concise, direct, RAG-status first | Long paragraphs, buried risks |
| Executive Summary | Strategic, headline-first | Technical details, acronyms without expansion |
| Technical Report | Methodical, evidence-based | Unsupported assertions |

**Universal rules:**
- Lead with the most important information — never bury the headline
- Every document has a clear **Action Required** section if one exists
- Numbers should be specific: "3 weeks" not "a few weeks", "£45k" not "significant cost"
- Use active voice: "We will deliver X" not "X will be delivered"

---

## SOW — Statement of Work

Save as: `Client-<Name>/Intake/YYYY-MM-DD_sow.md`

```markdown
# Statement of Work
**Client:** [Client Name]
**Engagement:** [Engagement Title]
**Date:** [YYYY-MM-DD]
**Version:** 1.0

---

## 1. Engagement Overview

[2–3 sentences: what we are doing, why, and what success looks like.]

## 2. Scope

### In Scope
- [Deliverable 1]
- [Deliverable 2]

### Out of Scope
- [Explicitly excluded item 1]
- [Explicitly excluded item 2]

## 3. Deliverables

| Deliverable | Description | Due Date | Format |
|---|---|---|---|
| [Name] | [What it is] | [Date] | [PDF / Dashboard / Model] |

## 4. Timeline

| Phase | Activities | Duration | Start | End |
|---|---|---|---|---|
| Discovery | [activities] | 1 week | [date] | [date] |
| Build | [activities] | 3 weeks | [date] | [date] |
| Review | [activities] | 1 week | [date] | [date] |

## 5. Assumptions & Dependencies

- [Client provides data access by [date]]
- [Stakeholder review completed within 3 business days of submission]

## 6. Commercials

| Item | Rate | Units | Total |
|---|---|---|---|
| [Role / Service] | [£/day] | [N days] | [£total] |

**Total Engagement Value: £[X,XXX]**

Payment terms: [e.g., 50% upfront, 50% on delivery]

## 7. Sign-Off

| | Client | Kubrick |
|---|---|---|
| Name | | |
| Signature | | |
| Date | | |
```

---

## Proposal Template

Save as: `Client-<Name>/Intake/YYYY-MM-DD_proposal.md`

```markdown
# Proposal: [Engagement Title]
**Prepared for:** [Client Name]
**Prepared by:** Sam McCain, Kubrick Group
**Date:** [YYYY-MM-DD]

---

## Executive Summary

[3 sentences: (1) The problem, (2) Our recommended approach, (3) The expected outcome.]

## The Problem

[Describe the client's challenge. Lead with business impact, not technical symptoms.]

## Our Approach

### Phase 1 — [Name] ([Duration])
[Brief description of activities and outputs]

### Phase 2 — [Name] ([Duration])
[Brief description of activities and outputs]

## Why Kubrick

- [Relevant credential 1]
- [Relevant credential 2]
- [Team composition relevant to this engagement]

## Investment

[Summary of commercial terms — reference SOW for detail]

## Next Steps

1. [Specific action] by [date]
2. [Specific action] by [date]
```

---

## Status Report Template

Save as: `Client-<Name>/Deliverables/YYYY-MM-DD_status-report.md`

```markdown
# Status Report — [Week of YYYY-MM-DD]
**Project:** [Engagement Title]
**Client:** [Client Name]
**Prepared by:** Sam McCain

---

## Overall Status: 🟢 On Track / 🟡 At Risk / 🔴 Blocked

## This Week

| Activity | Status | Owner |
|---|---|---|
| [Task] | Done ✅ | [Name] |
| [Task] | In Progress 🔄 | [Name] |

## Next Week

- [Planned activity 1]
- [Planned activity 2]

## Risks & Issues

| Risk/Issue | Severity | Mitigation |
|---|---|---|
| [Description] | High/Med/Low | [Action] |

## Decisions Required

> **Action Required from Client:** [Specific decision needed] by [date]

## Metrics

| KPI | Target | Actual | Status |
|---|---|---|---|
| [Metric] | [Value] | [Value] | 🟢/🟡/🔴 |
```

---

## Executive Summary Template

```markdown
# Executive Summary: [Report Title]

**Date:** [YYYY-MM-DD]
**Audience:** [C-suite / Steering Committee / Project Sponsor]

---

## Bottom Line

[One sentence: the single most important finding or recommendation.]

## Key Findings

1. **[Finding 1]:** [One sentence explanation + evidence]
2. **[Finding 2]:** [One sentence explanation + evidence]
3. **[Finding 3]:** [One sentence explanation + evidence]

## Recommendation

[Specific, actionable recommendation in 2–3 sentences. Include timeline and owner.]

## Next Steps

| Action | Owner | By When |
|---|---|---|
| [Action] | [Name/Team] | [Date] |
```

---

## File Naming Convention

All client-facing documents:

```
YYYY-MM-DD_document-type.ext
```

Examples:
```
2026-04-01_proposal.pdf
2026-04-15_sow-v2.pdf
2026-05-01_status-report-week3.pdf
2026-06-01_final-report.pdf
```

---

## Quality Checklist (Before Sending)

- [ ] No typos or grammar errors (re-read once after writing)
- [ ] No placeholder text remaining (`[Client Name]`, `[date]`, etc.)
- [ ] All numbers are specific (no "a few", "some", "significant")
- [ ] Action Required items are **bolded** and have an owner + date
- [ ] Filename follows `YYYY-MM-DD_title.ext` convention
- [ ] No internal Kubrick rates or margins visible to client
- [ ] Saved as PDF before sending (not .md or .docx to external parties)
