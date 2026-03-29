## Project Content/Scope

This workspace contains the **Consultant template** for MWP projects. Use it for AI & Data Analytics consulting engagements under the Kubrick Consulting umbrella:
- Client discovery and intake documentation
- Deliverables: reports, dashboards, data models, strategy decks
- Proposals and SOWs
- Business development tracking (pipeline, outreach, case studies)

**Context:** Kubrick Consulting places AI and data professionals at client organizations. Work is client-facing and professional. Deliverables must be clean, documented, and reproducible.

See: https://kubrickgroup.com/

---

## Workflow Orchestration

    1. Plan Mode Default
        - Enter plan mode for any non-trivial task (3+ steps or architectural decisions)
        - If something goes wrong, STOP and re-plan immediately
        - Use plan mode for verification steps, not just building
        - Write detailed specs upfront to reduce ambiguity

    2. Subagent Strategy
        - Use subagents liberally to keep main context window clean
        - Offload research, exploration, and parallel analysis to subagents
        - For complex problems, throw more compute at it via subagents
        - One task per subagent for focused execution

    3. Self-Improvement Loop
        - After ANY correction from the user: update rules/lessons.md
        - Write rules for yourself to prevent making the same mistake twice
        - Ruthlessly iterate on these lessons until mistake rate is dropped
        - Review lessons at session start for relevant project

    4. Verification Before Done
        - Never mark a task as done without proving it works
        - Diff behavior between main and your changes when relevant
        - Ask yourself: "Would a staff engineer approve of this?"
        - Run tests, check logs, demonstrate correctness

    5. Demand Elegance (balance)
        - For non-trivial changes: pause and ask "is there a more elegant solution?"
        - If a fix feels hacky: "Knowing everything I know now, implement the elegant solution."
        - Skip this for simple, obvious fixes — don't over-engineer
        - Challenge your own work before presenting it

    6. Autonomous Bug Fixing
        - When given a bug report: just fix it. Don't ask for hand-holding.
        - Point at logs, errors, and failing tests — then resolve them
        - Zero context switching required from the user
        - Go fix failing CI tests without being told how

---

## Workspaces/Clients

Each client engagement gets its own `Client-[Name]/` directory. Placeholder clients (`Client-Alpha`, `Client-Beta`) represent the scaffolding pattern — replace with real client names when onboarding.

| Directory | Purpose |
|---|---|
| `Client-[Name]/` | All files for a single client engagement |
| `templates/` | Reusable proposals, report formats, and delivery frameworks |
| `business-dev/` | BD pipeline, outreach tracking, and case studies |

---

## Task Management

- Use `Client-[Name]/Intake/` for briefs, notes, and SOWs at engagement start
- Use `Client-[Name]/Deliverables/` for all client-facing outputs
- Use `Client-[Name]/Communications/` for email threads, meeting notes, and status updates
- Track engagement milestones in a `task.md` at the client folder root
- Use the format: `YYYY-MM-DD_deliverable-name.ext` for all dated outputs

---

## Core Principles

    1. Agent-First — Delegate to specialized agents for domain tasks
    2. Documentation-First — Every deliverable must be self-explanatory without a verbal walkthrough
    3. Confidentiality — Never commit real client data, PII, or proprietary info to version control
    4. Reproducibility — Any analysis must be reproducible end-to-end from the documented steps
    5. Plan Before Execute — Plan complex features before writing code

---

## Folder Structure and Navigation

| Directory | Purpose | Context File |
|---|---|---|
| `Client-Alpha/` | Placeholder client — models the engagement structure | `Client-Alpha/CONTEXT.md` |
| `Client-Alpha/Intake/` | Briefs, SOWs, initial discovery notes | — |
| `Client-Alpha/Deliverables/` | Final client-facing outputs | — |
| `Client-Alpha/Communications/` | Email threads, meeting notes, status updates | — |
| `Client-Beta/` | Second placeholder client | — |
| `templates/` | Reusable document and analysis templates | `templates/CONTEXT.md` |
| `templates/Proposals/` | Proposal and SOW templates | — |
| `templates/Reports/` | Report and deliverable templates | — |
| `templates/Frameworks/` | Analytical frameworks and methodology docs | — |
| `business-dev/` | Business development tracking | `business-dev/CONTEXT.md` |
| `business-dev/pipeline/` | Active and prospective engagement pipeline | — |
| `business-dev/outreach/` | Outreach templates and tracking | — |
| `business-dev/case-studies/` | Anonymized project case studies for proposals | — |

---

## Rules

    1. Never commit real client data, API keys, or PII — use anonymized placeholders
    2. All deliverables must be dated: YYYY-MM-DD_title.ext
    3. Every Client-* directory must have a CONTEXT.md explaining the engagement
    4. Templates in templates/ must be fully anonymized — no traces of specific clients
    5. Communications are archived but never published externally from this repo
    6. Case studies in business-dev/ must be anonymized before use in proposals

---

## Naming Conventions

### Files
| Type | Convention | Example |
|---|---|---|
| Deliverables | `YYYY-MM-DD_title.ext` | `2026-03-25_q1-analysis.pdf` |
| Proposals | `proposal_vN.md` | `proposal_v2.md` |
| Meeting notes | `YYYY-MM-DD_meeting-topic.md` | `2026-03-25_kickoff-notes.md` |
| Reports | `YYYY-MM-DD_report-name.md` | `2026-03-25_data-audit.md` |
| Templates | `kebab-case.md` | `engagement-report-template.md` |

### Folders
| Type | Convention | Example |
|---|---|---|
| Client dirs | `Client-Name` (PascalCase) | `Client-Alpha/` |
| BD and template dirs | `kebab-case` | `business-dev/` |

### Git
| Type | Convention | Example |
|---|---|---|
| Client branches | `client/name-feature` | `client/alpha-data-audit` |
| Template updates | `chore/update-templates` | `chore/update-proposal-template` |
| BD tracking | `bd/pipeline-update` | `bd/q1-pipeline` |