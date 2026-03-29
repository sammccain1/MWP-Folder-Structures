# Folder-Structure-Consultant — Agent Context

You are operating inside the **Consultant workspace template** of MWP (Model Workspace Protocol).

## Who You're Working With

Sam is an **AI and Data Analytics Consultant** operating under **Kubrick Consulting** — a placement firm that embeds data and AI professionals into client organizations.

Current status: **Pre-client** (no active engagements). `Client-Alpha` and `Client-Beta` are placeholder scaffolding — not real clients.

## What This Template Is For

This directory is a **reusable consulting engagement scaffold**. When a new client engagement starts:
1. Clone this folder structure into the relevant project directory
2. Rename `Client-Alpha/` to `Client-[ActualName]/`
3. Fill in `Intake/` with briefs, SOW, and kick-off notes
4. Manage deliverables in `Deliverables/` — all dated `YYYY-MM-DD_title.ext`
5. Track the engagement with a `task.md` at the client folder root

**Do not use this template directory directly for live work.** It is structural scaffolding.

## Typical Deliverable Types

| Type | Format |
|---|---|
| Data analysis | Jupyter notebooks, R Markdown, CSV exports |
| Reports | Markdown → PDF, DOCX |
| Dashboards | Tableau, Power BI, or web-based (React + Supabase) |
| Strategy decks | PPTX or Google Slides |
| Proposals | Markdown or DOCX |

## Confidentiality Rules

- Never store real client data in version control — anonymize everything
- No PII, proprietary business data, or sensitive client info in this repo
- Case studies for BD use must be fully anonymized before committing

## When to Use Developer vs. Consultant

Use **Consultant** when: the work is for a Kubrick client — it's billable, client-facing, and tied to an engagement.
Use **Developer** when: building personal projects, ML experiments, or tools outside of client work.