## Project Content/Scope

This workspace contains the **Developer template** for MWP projects. Use it for:
- **ML & Data Science** — models, notebooks, training pipelines, evaluation scripts
- **Data & Automation Pipelines** — ETL, scraping, scheduling, data transformation
- **Web Applications** — full-stack apps (React/Next.js + FastAPI/PostgreSQL), APIs, Vercel deployments
- **Political Maps & Data Viz** — geographic data layers, interactive maps, GGplot/Matplotlib charts
- **Sports & Games** — simulation models, bracket engines, mini-game apps

**Primary Stack:**
- Languages: Python, JavaScript, TypeScript, R, SQL, HTML, CSS
- Frameworks/Libraries: React, Next.js, FastAPI, NumPy, Pandas, scikit-learn, GGplot, Matplotlib
- Tools: Docker, Git, Bash, Anaconda, Vercel, PostgreSQL, Supabase

**Working mode:** Solo for analytics, pipelines, and web projects. Collaborative for full-stack apps.

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
| `/new-project` | Scaffold from Developer template |
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

| Mode | Description |
|---|---|
| Solo | Analytics, automation pipelines, web projects — one developer, full ownership |
| Team | Full-stack apps — coordinate via PRs, feature branches, and shared planning docs |

Use `Planning/` for specs and decisions before writing any code. Keep `task.md` updated throughout the session.

---

## Task Management

- Use `Planning/specs/` for feature specs and PRDs before implementation
- Use `Planning/decisions/` for Architecture Decision Records (ADRs)
- Use `Planning/architecture/` for system diagrams and high-level design
- Maintain a `task.md` checklist at the project root using `[ ]` / `[/]` / `[x]` notation
- Break every feature into sub-tasks — no "implement feature X" without breakdown first

---

## Core Principles

    1. Agent-First — Delegate to specialized agents for domain tasks
    2. Test-Driven — Write tests before implementation, 80%+ coverage required
    3. Security-First — Never compromise on security; validate all inputs
    4. Immutability — Always create new objects, never mutate existing ones
    5. Plan Before Execute — Plan complex features before writing code

---

## Folder Structure and Navigation

| Directory | Purpose | Context File | Skills |
|---|---|---|---|
| `src/` | All source code: components, services, utils, tests | `src/CONTEXT.md` | — |
| `src/components/` | UI components (React/Next.js, PascalCase naming) | — | — |
| `src/services/` | Business logic, API calls, data access layer | — | — |
| `src/utils/` | Shared helpers, formatters, constants | — | — |
| `src/tests/` | Unit and integration tests co-located by module | — | — |
| `data/` | Raw, interim, and processed datasets | `data/CONTEXT.md` | — |
| `models/` | Trained model artifacts and versioned checkpoints | — | `ml-model` |
| `notebooks/` | Exploratory analysis and experiment notebooks | `notebooks/CONTEXT.md` | `ml-model`, `r-analysis` |
| `docs/` | Project documentation | `docs/CONTEXT.md` | — |
| `docs/guides/` | How-to guides and onboarding docs | — | — |
| `docs/api/` | API endpoint and schema documentation | — | — |
| `docs/changelog/` | Versioned release notes | — | — |
| `ops/` | Operations, automation, and deployment | `ops/CONTEXT.md` | — |
| `ops/scripts/` | ETL, automation, and bash scripts | — | `data-pipeline` |
| `ops/deploy/` | Docker, Vercel configs, CI/CD pipelines | — | — |
| `ops/monitoring/` | Logging, alerting, and observability configs | — | — |
| `Planning/` | Pre-implementation planning artifacts | `Planning/CONTEXT.md` | `planner` |
| `Planning/specs/` | Feature specs and PRDs | — | — |
| `Planning/decisions/` | Architecture Decision Records | — | — |
| `Planning/architecture/` | Diagrams and system design docs | — | — |
| `.gemini/skills/` | Agent skill modules — loaded on demand | — | — |
| `.gemini/skills/code-review/` | Stack-specific anti-patterns, severity guide, AI-code addenda | — | `SKILL.md` |
| `.gemini/skills/debugger/` | Debug commands, root-cause tables, CI failure patterns per stack | — | `SKILL.md` |
| `.gemini/skills/doc-writer/` | README, API, changelog, docstring templates + tone guide | — | `SKILL.md` |
| `.gemini/skills/e2e-testing/` | Playwright POM templates, selector strategy, CI config, flaky test remediation | — | `SKILL.md` |
| `.gemini/skills/planner/` | ADR template, Supabase schema plans, Next.js/ML pipeline templates, risk matrix | — | `SKILL.md` |
| `.gemini/skills/refactorer/` | Before/after recipes for Python, TypeScript, React + safe removal checklist | — | `SKILL.md` |
| `.gemini/skills/security-review/` | Full-stack security patterns, report template, PR checklist | — | `SKILL.md` |
| `.gemini/skills/data-pipeline/` | ETL, scraping, scheduling, idempotency patterns | — | `SKILL.md` |
| `.gemini/skills/data-viz/` | Matplotlib, ggplot2, Mapbox GL layer recipes | — | `SKILL.md` |
| `.gemini/skills/ml-model/` | sklearn lifecycle, LOSO CV, model versioning | — | `SKILL.md` |
| `.gemini/skills/r-analysis/` | tidyverse, toRvik, bracket simulation patterns | — | `SKILL.md` |
| `.gemini/skills/consultant-writer/` | SOW, proposals, status reports, executive summaries | — | `SKILL.md` |
| `.gemini/skills/frontend-design/` | Production-grade UI, design tokens, component patterns | — | `SKILL.md` |
| `.gemini/skills/ui-ux-design/` | WCAG, user flows, Tailwind + shadcn scaffolding | — | `SKILL.md` |
| `.gemini/skills/pen-testing/` | OWASP Top 10, Next.js + FastAPI attack vectors | — | `SKILL.md` |
| `.gemini/skills/web-animation/` | Remotion video production — see CONTEXT.md for sub-skills | — | `SKILL.md` |

---

## Rules

    1. Never mutate a Pandas DataFrame in place — always assign to a new variable
    2. Use TypeScript strict mode on all TS/TSX files
    3. Pin all Python dependencies in requirements.txt or environment.yml
    4. All React components must be typed with explicit Props interfaces
    5. SQL queries must use parameterized inputs — no string interpolation
    6. Keep notebooks (*.ipynb) in notebooks/ — never in ops/ or src/
    7. Secrets and API keys go in .env — always add .env to .gitignore
    8. Every new directory must include a CONTEXT.md

---

## Naming Conventions

### Files
| Type | Convention | Example |
|---|---|---|
| Python scripts | `snake_case.py` | `data_pipeline.py` |
| TypeScript components | `PascalCase.tsx` | `MapView.tsx` |
| TypeScript utils | `camelCase.ts` | `formatDate.ts` |
| Notebooks | `kebab-case.ipynb` | `mm-model-26.ipynb` |
| R scripts | `snake_case.R` | `bracket_sim.R` |
| Markdown docs | `kebab-case.md` | `getting-started.md` |
| SQL migrations | `YYYY-MM-DD_description.sql` | `2026-03-25_add_users_table.sql` |

### Folders
| Type | Convention | Example |
|---|---|---|
| Feature dirs | `kebab-case` | `election-map/` |
| Module dirs | `kebab-case` | `data-pipeline/` |

### Git
| Type | Convention | Example |
|---|---|---|
| Feature branches | `feat/short-description` | `feat/political-map-layer` |
| Bug fixes | `fix/short-description` | `fix/pipeline-null-error` |
| Data branches | `data/dataset-name` | `data/mm-2026-season` |
| Chores | `chore/short-description` | `chore/update-deps` |

### Variables & Code
- Python: `snake_case` for variables/functions, `PascalCase` for classes, `SCREAMING_SNAKE_CASE` for constants
- TypeScript: `camelCase` for variables/functions, `PascalCase` for components and types
- SQL/DB: `snake_case` for all table and column names
- R: `snake_case` throughout