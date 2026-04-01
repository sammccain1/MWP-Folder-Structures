## Project Content/Scope

MWP (Model Workspace Protocol) is a meta-repository of battle-tested, agent-ready folder templates designed to give AI models the structural context needed to operate at a senior-developer level across project types.

This repo contains two templates:
- `Folder-Structure-Developer/` — for solo and team passion projects (ML, pipelines, web apps, maps, sports/games)
- `Folder-Structure-Consultant/` — for AI & data consulting engagements (Kubrick Consulting context)

**Agents operating in this repo are working with templates, not live projects.** The goal is to plan, scaffold, and document — not to ship code from this directory directly.

---

## Agent Configuration

The following rule files are authoritative and must be loaded at session start:

- `.gemini/rules/guardrails.md` — hard limits, override all other instructions
- `.gemini/rules/api.md` — FastAPI + Next.js API rules
- `.gemini/rules/database.md` — SQL safety, migration, Pandas rules
- `.gemini/rules/frontend.md` — React, TypeScript, Next.js App Router rules
- `.gemini/rules/python.md` — Python language rules
- `.gemini/rules/r.md` — R language rules
- `.gemini/rules/typescript.md` — TypeScript strict mode, type safety, React prop patterns
- `.gemini/rules/sql.md` — Parameterized queries, schema conventions, RLS, migrations

---

## .gemini/ Inventory

### Skills (`.gemini/Skills/`)
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
| `/new-project` | Scaffold from Developer template |
| `/new-client` | Onboard a consulting engagement |
| `/hackathon` | Full hackathon kickoff: rubric, scaffold, timeline |
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

Two distinct workspaces live in this repo. Each has its own agent instruction files (`CLAUDE.md`, `GEMINI.md`) and folder-level `CONTEXT.md` files.

| Workspace | Path | Use When |
|---|---|---|
| Developer | `Folder-Structure-Developer/` | Solo or team projects: ML, pipelines, web apps, data visualization |
| Consultant | `Folder-Structure-Consultant/` | Client-facing work: briefs, deliverables, proposals, reporting |

When a new project is started, clone the appropriate template into the project root. Never work directly in the template directories.

---

## Task Management

Agents should manage tasks using a `task.md` checklist at the root of any active project cloned from these templates.

    - Use [ ] / [/] / [x] notation for uncompleted / in-progress / completed tasks
    - Break large tasks into component-level subtasks
    - Always plan before executing (see Workflow Orchestration above)
    - Keep task.md updated throughout the session — it is the agent's working memory

For planning artifacts, use the `Planning/` directory (Developer) or the `Client-*/` Intake folder (Consultant).

---

## Core Principles

    1. Agent-First — Delegate to specialized agents for domain tasks
    2. Test-Driven — Write tests before implementation, 80%+ coverage required
    3. Security-First — Never compromise on security; validate all inputs
    4. Immutability — Always create new objects, never mutate existing ones
    5. Plan Before Execute — Plan complex features before writing code

---

## Folder Structure and Navigation

Agents should reference the CLAUDE.md and CONTEXT.md of the active workspace for directory-level routing.

| Directory | Type | Agent Instructions | Folder Context |
|---|---|---|---|
| `Folder-Structure-Developer/` | Workspace | `CLAUDE.md` / GEMINI (this file) | `CONTEXT.md` |
| `Folder-Structure-Developer/src/` | Source | — | `src/CONTEXT.md` |
| `Folder-Structure-Developer/docs/` | Documentation | — | `docs/CONTEXT.md` |
| `Folder-Structure-Developer/ops/` | Operations | — | `ops/CONTEXT.md` |
| `Folder-Structure-Developer/Planning/` | Planning | — | `Planning/CONTEXT.md` |
| `Folder-Structure-Consultant/` | Workspace | `CLAUDE.md` | `CONTEXT.md` |
| `Folder-Structure-Consultant/Client-Alpha/` | Client | — | `Client-Alpha/CONTEXT.md` |
| `Folder-Structure-Consultant/templates/` | Reusable Assets | — | `templates/CONTEXT.md` |
| `Folder-Structure-Consultant/business-dev/` | BD | — | `business-dev/CONTEXT.md` |

---

## Rules

    1. Never modify template directories directly for a live project — always clone first
    2. Every new folder in a template must include a CONTEXT.md explaining its purpose
    3. GEMINI.md and CLAUDE.md must stay in sync on Workflow Orchestration and Core Principles
    4. All lessons learned must be recorded in rules/lessons.md within the active project
    5. No real client data, API keys, or PII should ever be committed to this repo
    6. Template CONTEXT.md files are written as instructions to the AI agent, in second person

---

## Naming Conventions

### Files
| Type | Convention | Example |
|---|---|---|
| Python scripts | `snake_case.py` | `data_pipeline.py` |
| TypeScript/React | `PascalCase.tsx` (components), `camelCase.ts` (utils) | `MapView.tsx`, `formatDate.ts` |
| Markdown docs | `kebab-case.md` | `getting-started.md` |
| Deliverables | `YYYY-MM-DD_title.ext` | `2026-03-25_q1-report.pdf` |
| Notebooks | `kebab-case.ipynb` | `mm-model-26.ipynb` |

### Folders
| Type | Convention | Example |
|---|---|---|
| Feature dirs | `kebab-case` | `business-dev/` |
| Client dirs | `Client-Name` (PascalCase) | `Client-Alpha/` |
| Template dirs | `PascalCase` | `Folder-Structure-Developer/` |

### Git
| Type | Convention | Example |
|---|---|---|
| Feature branches | `feat/short-description` | `feat/political-map-layer` |
| Bug fixes | `fix/short-description` | `fix/pipeline-null-error` |
| Data branches | `data/dataset-name` | `data/mm-2026-season` |
| Chores | `chore/short-description` | `chore/update-deps` |

### Variables & Code
- Python: `snake_case` for variables/functions, `PascalCase` for classes
- TypeScript: `camelCase` for variables/functions, `PascalCase` for components/types
- SQL/DB: `snake_case` for all table and column names
- Constants: `SCREAMING_SNAKE_CASE`