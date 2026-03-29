---
name: new-client
description: Onboard a new consulting engagement from the Folder-Structure-Consultant template. Creates a Client-Name directory, populates intake docs, and sets up task.md. Use when starting any new Kubrick or freelance client engagement.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /new-client

Use this command to **onboard a new consulting engagement**. Never work directly in `Folder-Structure-Consultant/` — always follow this workflow.

---

## Required Inputs

Confirm before starting:

| Input | Example |
|---|---|
| `CLIENT_NAME` | `Barclays` (`PascalCase`, no spaces) |
| `ENGAGEMENT_TYPE` | `data-strategy` \| `ml-build` \| `analytics` \| `etl-pipeline` \| `reporting` |
| `START_DATE` | `2026-04-01` |
| `CONTACT_NAME` | Primary stakeholder name |
| `BRIEF_SUMMARY` | One-line description of the engagement |

---

## Step 1 — Create the client directory

```bash
CONSULTANT_ROOT="/Users/sammccain/ProjectFolderBuilder/MWP-Folder-Structures/Folder-Structure-Consultant"
CLIENT="<CLIENT_NAME>"

# Copy Client-Alpha template as the base
cp -r "$CONSULTANT_ROOT/Client-Alpha" "$CONSULTANT_ROOT/Client-$CLIENT"

echo "Client directory created: Client-$CLIENT"
```

---

## Step 2 — Populate intake docs

In `Client-<CLIENT_NAME>/Intake/`, create or update:

### `brief.md` — Engagement Brief
```markdown
# Engagement Brief: <CLIENT_NAME>

**Type:** <ENGAGEMENT_TYPE>
**Start Date:** <START_DATE>
**Primary Contact:** <CONTACT_NAME>
**Summary:** <BRIEF_SUMMARY>

## Business Problem
[What is the client trying to solve?]

## Success Criteria
- [ ] [Define measurable outcomes]

## Constraints
- Timeline:
- Budget:
- Data access:
- Tech stack requirements:

## Key Stakeholders
| Name | Role | Communication Preference |
|---|---|---|
| <CONTACT_NAME> | [Role] | [Email / Slack / Weekly call] |
```

### `data-inventory.md` — Data Assets
```markdown
# Data Inventory: <CLIENT_NAME>

| Dataset | Format | Owner | Access Method | Notes |
|---|---|---|---|---|
| [Name] | CSV/DB/API | [Team] | [How to get it] | [Quality notes] |
```

---

## Step 3 — Create task.md

```markdown
# <CLIENT_NAME> Engagement

**Type:** <ENGAGEMENT_TYPE>
**Start:** <START_DATE>

## Intake
- [ ] Brief confirmed with client
- [ ] Data inventory complete
- [ ] Access credentials received (stored in 1Password, NOT in repo)
- [ ] NDA / DPA signed

## Delivery
- [ ] [Phase 1 deliverable]
- [ ] [Phase 2 deliverable]

## Sign-Off
- [ ] Client review session scheduled
- [ ] Feedback incorporated
- [ ] Final deliverable delivered
- [ ] Billing confirmed
```

---

## Step 4 — Security checklist

Before adding any client data:

- [ ] Confirm `.gitignore` excludes `data/`, `*.csv`, `*.xlsx`, `*.parquet`
- [ ] Verify no PII fields are included in sample data
- [ ] Credentials stored in 1Password, not in the repo
- [ ] Run `secrets-check.sh` before every commit during this engagement

---

## Step 5 — Initial commit

```bash
cd "$CONSULTANT_ROOT"
git add "Client-$CLIENT"
git commit -m "feat: onboard Client-$CLIENT engagement ($ENGAGEMENT_TYPE)"
```

---

## Notes

- Client directories follow `Client-<PascalCaseName>` naming, matching existing `Client-Alpha`
- Never store real client data in this repo — deliverables live in `Client-*/Deliverables/` but data lives in separate secure storage
- SOW and proposals go in `Client-*/Intake/` — use the `consultant-writer` skill to draft them
- Billing and contract docs are tracked by filename date prefix: `YYYY-MM-DD_title.ext`
