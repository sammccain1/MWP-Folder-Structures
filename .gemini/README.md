# .gemini/ — MWP Agent Configuration

This directory is the **brain of the Model Workspace Protocol (MWP)**. It configures how
AI agents (Gemini CLI, Claude Code, and compatible tools) think, behave, and operate across
all MWP projects.

You are an agent reading this at session start. This README is your navigation guide.
Read it once, understand the system, then use the subsystems described below.

---

## How This System Works

```
.gemini/
├── settings.json        ← Wires hooks, model config, and tool permissions
├── rules/               ← WHAT the agent must/must not do (loaded every session)
├── skills/              ← HOW to do specific tasks (loaded on demand)
├── commands/            ← WHEN the user invokes /slash-commands
├── hooks/               ← AUTOMATED scripts that fire on lifecycle events
└── memory/              ← PERSISTENT state across sessions
```

The agent's job is:
1. **Always follow** `rules/` — these are hard constraints
2. **Load skills** on demand when a task matches a skill description
3. **Execute commands** when the user types `/command-name`
4. **Trust hooks** to run automatically — don't replicate their work manually
5. **Update memory** at session end via `/sync-memory`

---

## `rules/` — Guardrails (Always Active)

Rules are loaded at every session start. They define hard constraints and coding standards.

**Start here for any new session:** Read `rules/guardrails.md` first — it overrides everything.

| File | When It Applies |
|---|---|
| `guardrails.md` | Every session — hard limits, secrets, scope, commit discipline |
| `python.md` | Any Python code — FastAPI, Pydantic, sklearn, pytest |
| `typescript.md` | Any TypeScript — strict mode, branded types, React typing |
| `reactjs.md` | Any React component — hooks rules, memoization, error boundaries |
| `frontend.md` | Any Next.js work — Server/Client components, TanStack Query, Server Actions |
| `api.md` | Any API work — FastAPI routes, Next.js handlers, rate limiting, CORS |
| `database.md` | Any DB work — async SQLAlchemy, migrations, connection pooling |
| `sql.md` | Any raw SQL — parameterized queries, schema design, RLS |
| `pandas.md` | Any Pandas — no inplace, vectorization, Parquet |
| `r.md` | Any R — {targets}, {pointblank}, ggplot2, furrr |
| `bash.md` | Any shell scripts — set -euo pipefail, quoting, stderr/stdout |
| `docker.md` | Any Dockerfile — pinned tags, non-root user, multi-stage |
| `git.md` | Any git operation — commit format, branch naming, forbidden ops |
| `css.md` | Any CSS — custom properties, WCAG, CSS Modules, responsive units |

> See `rules/CONTEXT.md` for the full index and `/add-rule` to create a new rule file.

---

## `skills/` — Capabilities (Load on Demand)

Skills are loaded **only when a task matches**. Do not pre-load all skills.

**Decision rule:** Read the skill's `description:` field in `SKILL.md` frontmatter.
If the current task matches, load and follow the skill.

| Skill | Load When... |
|---|---|
| `planner` | Multi-step planning, ADRs, architecture decisions |
| `code-review` | PR review, diff analysis |
| `debugger` | Bug reports, failing tests, unexpected behavior |
| `refactorer` | Tech debt, deduplication, legacy modernization |
| `doc-writer` | READMEs, API docs, CONTEXT.md files, changelogs |
| `security-review` | Pre-delivery security sweeps, auth review |
| `pen-testing` | OWASP Top 10 assessment, attack vector analysis |
| `e2e-testing` | Playwright tests, flaky test remediation, CI E2E config |
| `ml-model` | Sklearn, LOSO CV, feature engineering, model versioning |
| `data-pipeline` | ETL scripts, scrapers, scheduled jobs, idempotency |
| `data-viz` | Matplotlib, Seaborn, ggplot2, Mapbox GL layers |
| `r-analysis` | toRvik data, tidyverse wrangling, bracket simulation |
| `frontend-design` | Production-grade UI, design tokens, bold aesthetics |
| `ui-ux-design` | WCAG2AA, user flows, component hierarchy |
| `consultant-writer` | SOWs, proposals, status reports, executive summaries |
| `supabase` | Auth, RLS, Edge Functions, Storage, Realtime |
| `geospatial` | Mapbox GL JS, GeoJSON, choropleth maps, geopandas |
| `git-workflow` | Branching strategy, commit conventions, rebase/merge |
| `performance` | Next.js bundle analysis, Core Web Vitals, cProfile |
| `test-driven` | TDD red-green-refactor, pytest fixtures, Jest/Vitest |
| `web-animation` | Remotion video — load sub-skills as needed |

**`web-animation` sub-skills** (load the specific one, not the parent):

| Sub-skill | Load When... |
|---|---|
| `web-animation/spec-writing` | Starting a new Remotion video |
| `web-animation/style-guide` | Color, typography, or margin decisions |
| `web-animation/visual-direction` | Translating creative intent to animation |
| `web-animation/animation-primitives` | Writing animation code (`spring()`, `interpolate()`) |
| `web-animation/composition-structure` | Multi-scene composition (`Series`, `Sequence`) |
| `web-animation/common-patterns` | Specific effects (stagger, typewriter, counter) |
| `web-animation/rendering` | Exporting final video — codec, render commands |

---

## `commands/` — Slash Commands

Commands are invoked when the user types `/command-name`. Each `.md` file is a
step-by-step workflow to execute.

| Command | Purpose |
|---|---|
| `/standup` | Session-start briefing: task.md + git log + tests |
| `/new-project` | Scaffold from Developer template |
| `/new-client` | Onboard a consulting engagement |
| `/hackathon` | Full hackathon kickoff: rubric, scaffold, timeline |
| `/checkpoint` | Mid-session save: task.md + secrets check + commit |
| `/review` | Full pre-delivery QA: secrets, deps, lint, tests, a11y |
| `/pen-test` | Structured OWASP security assessment |
| `/debug` | Structured debug session: reproduce → bisect → fix → regression |
| `/deploy` | Deployment pre-flight + rollback plan |
| `/pr-review` | PR review checklist |
| `/db-migrate` | Guided migration: timestamped SQL file, rollback, RLS, local test |
| `/report` | Generate client-ready status report from task.md + git log |
| `/clean` | Remove build artifacts, caches, stale branches |
| `/add-rule` | Add a new language/domain rule file |
| `/sync-memory` | End-of-session memory sync to standing-decisions.md |

---

## `hooks/` — Lifecycle Automation

Hooks run automatically on Gemini CLI lifecycle events. **Do not invoke these manually**
unless debugging. They are wired in `settings.json`.

| Hook | Fires On | Behavior |
|---|---|---|
| `session-start.sh` | Session start | Prints repo context, branch, task.md status, recent commits |
| `secrets-check.sh` | Before every tool call | **Hard blocks** (exit 2) if secrets found in staged changes |
| `pre-commit.sh` | Before shell tool calls | Git snapshot before destructive shell operations |
| `dependency-check.sh` | Before shell tool calls | Scans npm/pip for CVEs — advisory only (exit 0) |
| `lint-on-save.sh` | After any file write | Runs ruff/tsc — advisory only (exit 0) |
| `test-on-change.sh` | After source file writes | Runs pytest/npm test — advisory only (exit 0) |
| `accessibility-check.sh` | After UI file writes | Runs pa11y WCAG2AA — advisory only (exit 0) |
| `post-tool.sh` | After every tool call | Appends structured entry to `rules/audit.log` |

**Severity policy:** Only `secrets-check.sh` hard-blocks. All others are advisory and
always exit 0 to avoid interrupting unrelated agent tool calls.

---

## `memory/` — Persistent State

The memory directory persists knowledge across sessions.

| File / Dir | Purpose |
|---|---|
| `standing-decisions.md` | Global architectural decisions — treated as defaults without re-litigation |
| `client-context/` | Per-client context snapshots for the Consultant workspace |
| `README.md` | Memory system documentation |

**Session end protocol:** Run `/sync-memory` to write new decisions to
`standing-decisions.md` before closing the session.

---

## `settings.json` — CLI Wiring

Wires everything together for the Gemini CLI:
- Model selection and generation config
- Hook registration (event → script mapping)
- Tool permissions per context

**Do not edit `settings.json`** during a session. Changes require a CLI restart to take
effect. Use `/add-rule` or `/sync-memory` workflows instead.

---

## Extension Guide

### Adding a new rule
```
/add-rule
→ Creates .gemini/rules/<domain>.md
→ Update GEMINI.md, CLAUDE.md, and rules/CONTEXT.md
```

### Adding a new skill
```
→ Create .gemini/skills/<name>/SKILL.md with YAML frontmatter:
  ---
  name: skill-name
  description: One sentence — when should this skill be loaded?
  ---
→ Add it to the skills table in GEMINI.md, CLAUDE.md, and this README
```

### Adding a new command
```
→ Create .gemini/commands/<name>.md with frontmatter:
  ---
  name: command-name
  description: What this command does
  allowed_tools: ["Bash", "Read", "Write"]
  ---
→ Add it to the commands table in GEMINI.md, CLAUDE.md, and this README
```
