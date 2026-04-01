## Project Content/Scope

This workspace contains the **Consultant template** for MWP projects. Use it for AI & Data Analytics consulting engagements under the Kubrick Consulting umbrella:
- Client discovery and intake documentation
- Deliverables: reports, dashboards, data models, strategy decks
- Proposals and SOWs
- Business development tracking (pipeline, outreach, case studies)

**Context:** Kubrick Consulting places AI and data professionals at client organizations. Work is client-facing and professional. Deliverables must be clean, documented, and reproducible.

See: https://kubrickgroup.com/

---

## Agent Configuration

The following rule files are authoritative and must be loaded at session start:

- `.gemini/rules/guardrails.md` — hard limits, override all other instructions
- `.gemini/rules/api.md` — FastAPI + Next.js API rules
- `.gemini/rules/database.md` — SQL safety, migration, Pandas rules
- `.gemini/rules/frontend.md` — React, TypeScript, Next.js App Router rules
- `.gemini/rules/python.md` — Python language rules
- `.gemini/rules/r.md` — R language rules
- `.gemini/rules/reactjs.md` — React component patterns, hooks, and state management
- `.gemini/rules/typescript.md` — TypeScript strict mode, type safety, React prop patterns
- `.gemini/rules/sql.md` — Parameterized queries, schema conventions, RLS, migrations

---

## .gemini/ Inventory

### Skills (`.gemini/skills/`)
| Skill | Trigger |
|---|---|
| `planner` | Any multi-step planning task, ADRs, architecture decisions |
| `code-review` | PR reviews, diff analysis, pre-delivery code quality |
| `debugger` | Bug reports, failing tests, unexpected behaviour |
| `refactorer` | Tech debt, deduplication, modernising legacy patterns |
| `doc-writer` | READMEs, API docs, changelogs, docstrings, CONTEXT.md files |
| `security-review` | Pre-delivery security sweeps, auth review, input validation |
| `e2e-testing` | Playwright tests, flaky test remediation, CI E2E config |
| `ml-model` | Sklearn models, LOSO CV, feature engineering, model versioning |
| `data-pipeline` | ETL scripts, scrapers, scheduled jobs, idempotency patterns |
| `data-viz` | Matplotlib/Seaborn charts, ggplot2, Mapbox GL layer recipes |
| `r-analysis` | toRvik data access, tidyverse wrangling, bracket simulation |
| `consultant-writer` | SOWs, proposals, status reports, executive summaries |
| `frontend-design` | Production-grade UI, design tokens, component aesthetics |
| `ui-ux-design` | WCAG2AA, user flows, component hierarchy, Tailwind + shadcn |
| `pen-testing` | OWASP Top 10, Next.js + FastAPI attack vectors, findings report |
| `web-animation` | **Entry point:** any Remotion/programmatic video task. Then load sub-skills: |
| `web-animation/spec-writing` | Starting a new video — write the spec before any code |
| `web-animation/style-guide` | Color, typography, or margin decisions |
| `web-animation/visual-direction` | Translating creative intent into animation vocabulary |
| `web-animation/animation-primitives` | Writing animation code — `useCurrentFrame()`, `spring()`, `interpolate()` |
| `web-animation/composition-structure` | Multi-scene composition — `Series`, `Sequence`, scene templates |
| `web-animation/common-patterns` | Specific effects: stagger, typewriter, counter, crossfade |
| `web-animation/rendering` | Exporting final video — codec, render commands, troubleshooting |

### Hooks (`.gemini/hooks/`) — wired via `settings.json`
| Hook | Event | Purpose |
|---|---|---|
| `session-start.sh` | `SessionStart` | Print repo context, task.md status, recent commits |
| `secrets-check.sh` | `BeforeTool` (all) | Block secrets from being written or committed |
| `pre-commit.sh` | `BeforeTool` (shell) | Git snapshot before shell commands |
| `dependency-check.sh` | `BeforeTool` (shell) | Scan npm/pip for CVEs before installs |
| `post-tool.sh` | `AfterTool` (all) | Structured audit log entry after every tool |
| `lint-on-save.sh` | `AfterTool` (file writes) | Run linter after any file change |
| `test-on-change.sh` | `AfterTool` (file writes) | Run tests for changed source files |
| `accessibility-check.sh` | `AfterTool` (file writes) | WCAG2AA check after UI changes |

### Commands (`.gemini/commands/`) — invoke with `/command-name`
| Command | Purpose |
|---|---|
| `/standup` | Session-start briefing: task.md + git log + tests |
| `/new-client` | Onboard a consulting engagement |
| `/checkpoint` | Mid-session save: task.md + secrets check + commit |
| `/review` | Full pre-delivery QA: secrets, deps, lint, tests, a11y |
| `/pen-test` | Structured security assessment workflow |
| `/clean` | Remove build artifacts, caches, stale branches |
| `/deploy` | Deployment pre-flight + rollback plan |
| `/pr-review` | PR review checklist |
| `/fix-issue` | Bug fix workflow |
| `/add-rule` | Add a new language/domain rule file |
| `/sync-memory` | End-of-session memory sync to knowledge graph + standing-decisions.md |
| `/report` | Generate client-ready status report from task.md + git log |
| `/db-migrate` | Guided migration: timestamped SQL file, rollback, RLS, local test |
| `/debug` | Structured debug session: reproduce → bisect → fix → regression test |

---

## Gemini CLI Usage Notes

- **Hooks use `stdout` for JSON only** — all logging in hook scripts must go to `stderr` (`echo "..." >&2`). Any `echo` to stdout breaks the Gemini CLI JSON parser.
- **Exit code 2 = hard block** — a hook exiting with code 2 will abort the tool call and surface the stderr message to the agent.
- **Exit code 0 = proceed** — return `{"decision": "deny", "reason": "..."}` on stdout to soft-block with a message.
- **`/rewind`** — use inside a Gemini CLI session to undo the last agentic step if something goes wrong.
- **`Control+B`** — keep a dev server running in the background without blocking the agent.
- **Skills are loaded on demand** — the agent reads `SKILL.md` descriptions and injects the relevant file when it detects a matching task.

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
| `Client-Beta/` | Second placeholder client — mirrors Client-Alpha structure | `Client-Beta/CONTEXT.md` |
| `Client-Beta/Intake/` | Briefs, SOWs, initial discovery notes | — |
| `Client-Beta/Deliverables/` | Final client-facing outputs | — |
| `Client-Beta/Communications/` | Email threads, meeting notes, status updates | — |
| `templates/` | Reusable document and analysis templates | `templates/CONTEXT.md` |
| `templates/Proposals/` | Proposal and SOW templates | — |
| `templates/Reports/` | Report and deliverable templates | — |
| `templates/Frameworks/` | Analytical frameworks and methodology docs | — |
| `business-dev/` | Business development tracking | `business-dev/CONTEXT.md` |
| `business-dev/pipeline/` | Active and prospective engagement pipeline | — |
| `business-dev/outreach/` | Outreach templates and tracking | — |
| `business-dev/case-studies/` | Anonymized project case studies for proposals | — |

---

## Agent Protocol

### Skills to Load by Task

| Task | Load This Skill |
|---|---|
| Writing SOWs, proposals, status reports | `.gemini/skills/consultant-writer/SKILL.md` |
| Data analysis or pipeline work | `.gemini/skills/data-pipeline/SKILL.md` |
| Visualizations for client deliverables | `.gemini/skills/data-viz/SKILL.md` |
| Security review before client handoff | `.gemini/skills/security-review/SKILL.md` |
| Code review on deliverable code | `.gemini/skills/code-review/SKILL.md` |
| Writing technical documentation | `.gemini/skills/doc-writer/SKILL.md` |
| Programmatic video or animation | `.gemini/skills/web-animation/SKILL.md` |

### Commands for Consultant Workflow

| Command | When to Use |
|---|---|
| `/new-client` | Starting any new engagement — never work directly in templates |
| `/standup` | Start of every session — reads task.md and last-session memory |
| `/checkpoint` | Before any risky operation or stepping away mid-task |
| `/report` | Before client syncs, weekly standups, end-of-sprint |
| `/sync-memory` | End of every session — writes to `.gemini/memory/client-context/` |
| `/review` | Before any client deliverable handoff |
| `/deploy` | When deploying client-facing applications |

### Session Memory

At session end, always run `/sync-memory`. This writes to:
- `.gemini/memory/client-context/[Client-Name]-last-session.md` — picked up by `/standup` next session
- `.gemini/memory/standing-decisions.md` — for architectural decisions that span engagements

### Confidentiality Enforcement

The `secrets-check` hook runs automatically before every tool call. Additionally:
- Never paste real client data into prompts — describe the structure, not the values
- If working with sensitive data locally, reference the external secure path — don't copy files here

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
