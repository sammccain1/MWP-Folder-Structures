# Client-Alpha/ — Client Engagement Directory

You are in a **client engagement directory**. This is a placeholder client (`Client-Alpha`) that models the standard engagement structure. Replace with a real client name when onboarding.

## Subdirectory Guide

| Directory | Purpose |
|---|---|
| `Intake/` | Discovery documents: project brief, Statement of Work (SOW), kick-off notes, initial data audit |
| `Deliverables/` | All final client-facing outputs. Named `YYYY-MM-DD_deliverable-name.ext`. |
| `Communications/` | Email threads, meeting notes, and status updates. Named `YYYY-MM-DD_topic.md`. |

## Rules for This Directory

- Keep a `task.md` at this directory root to track the engagement lifecycle
- Intake documents capture the scope — anything out of scope must be documented as a change request
- Deliverables are the only files shared with clients — everything else stays internal
- All meeting notes should be written up within 24 hours of the meeting
- Never store raw client data here — reference external secure storage, or anonymize it first

## Engagement Lifecycle

```
Intake → Active Development → Review → Delivery → Archived
```

When an engagement is complete, archive the `Client-[Name]/` folder and remove it from active development.
