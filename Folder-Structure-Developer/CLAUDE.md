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
| `docs/` | Project documentation | `docs/CONTEXT.md` | — |
| `docs/guides/` | How-to guides and onboarding docs | — | — |
| `docs/api/` | API endpoint and schema documentation | — | — |
| `docs/changelog/` | Versioned release notes | — | — |
| `ops/` | Operations, automation, and deployment | `ops/CONTEXT.md` | — |
| `ops/scripts/` | ETL, automation, and bash scripts | — | — |
| `ops/deploy/` | Docker, Vercel configs, CI/CD pipelines | — | — |
| `ops/monitoring/` | Logging, alerting, and observability configs | — | — |
| `Planning/` | Pre-implementation planning artifacts | `Planning/CONTEXT.md` | — |
| `Planning/specs/` | Feature specs and PRDs | — | — |
| `Planning/decisions/` | Architecture Decision Records | — | — |
| `Planning/architecture/` | Diagrams and system design docs | — | — |
| `.gemini/agents/skills/` | Agent skill modules — loaded on demand | — | — |
| `.gemini/agents/skills/code-review/` | Stack-specific anti-patterns, severity guide, AI-code addenda | — | `SKILL.md` |
| `.gemini/agents/skills/debugger/` | Debug commands, root-cause tables, CI failure patterns per stack | — | `SKILL.md` |
| `.gemini/agents/skills/doc-writer/` | README, API, changelog, docstring templates + tone guide | — | `SKILL.md` |
| `.gemini/agents/skills/e2e-testing/` | Playwright POM templates, selector strategy, CI config, flaky test remediation | — | `SKILL.md` |
| `.gemini/agents/skills/planner/` | ADR template, Supabase schema plans, Next.js/ML pipeline templates, risk matrix | — | `SKILL.md` |
| `.gemini/agents/skills/refactorer/` | Before/after recipes for Python, TypeScript, React + safe removal checklist | — | `SKILL.md` |
| `.gemini/agents/skills/security-review/` | Full-stack security patterns, report template, PR checklist | — | `SKILL.md` |

---

## Rules

    1. Never mutate a Pandas DataFrame in place — always assign to a new variable
    2. Use TypeScript strict mode on all TS/TSX files
    3. Pin all Python dependencies in requirements.txt or environment.yml
    4. All React components must be typed with explicit Props interfaces
    5. SQL queries must use parameterized inputs — no string interpolation
    6. Keep notebooks (*.ipynb) in src/ or a dedicated notebooks/ folder — never in ops/
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