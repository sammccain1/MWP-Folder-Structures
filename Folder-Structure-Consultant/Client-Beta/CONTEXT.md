# Client-Beta/ — Client Engagement Directory

You are in a **client engagement directory**. This is a placeholder client (`Client-Beta`) that models a **data migration and infrastructure engagement** — contrast with `Client-Alpha` which models an analytics/reporting engagement.

## Engagement Type

Client-Beta represents a data engineering / platform migration project:
- Migrating legacy data infrastructure to a modern stack (e.g., on-prem → cloud, flat files → Supabase/PostgreSQL)
- Building reproducible ETL pipelines
- Documenting data lineage and quality rules
- Deliverables are technical: pipeline code, schema docs, data quality reports — not strategy decks

## Subdirectory Guide

| Directory | Purpose |
|---|---|
| `Intake/` | Discovery: existing system audit, data inventory, migration scope definition, SOW |
| `Deliverables/` | Pipeline code, schema migration scripts, data quality reports, runbooks. Named `YYYY-MM-DD_deliverable-name.ext`. |
| `Communications/` | Technical meeting notes, architecture decisions made with the client. Named `YYYY-MM-DD_topic.md`. |

## Rules for This Directory

- Keep a `task.md` at this directory root tracking the migration phases: `Audit → Schema Design → Pipeline Build → Validation → Cutover`
- All pipeline scripts delivered here must be runnable standalone — no undocumented dependencies
- Data quality rules agreed with the client go in `Intake/` as a living document, updated as scope evolves
- Never store raw source data here — reference the agreed secure transfer location in `Intake/`
- Deliverables that include SQL migrations must also include the rollback migration

## Engagement Lifecycle

```
Intake → Schema Design → Pipeline Build → Data Validation → Cutover → Handover → Archived
```

Cutover and handover require explicit client sign-off documented in `Communications/`.

## Key Difference from Client-Alpha

Client-Alpha is analytics/reporting — the deliverable is insight. Client-Beta is infrastructure/migration — the deliverable is a working, documented system the client's team can operate without you.
