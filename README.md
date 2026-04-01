# MWP — Model Workspace Protocol

A battle-tested agent protocol and folder structure system for AI-assisted development. MWP gives AI agents (Gemini CLI, Claude Code) the structural context, rules, skills, and memory they need to operate at a senior-developer level across project types.

---

## What MWP Is

MWP is not just a folder structure — it is a full agent operating protocol. When you clone a workspace and start a session, the agent knows:

- **What it's allowed to do** — via rules and guardrails
- **How to do it well** — via skills loaded on demand
- **Where things live** — via CONTEXT.md files in every directory
- **What happened before** — via session memory and lessons
- **How to stay safe** — via hooks that run automatically on every tool call

---

## Repository Structure

```
MWP-Folder-Structures/
├── Folder-Structure-Developer/   # Template for ML, pipelines, web apps, maps, simulations
├── Folder-Structure-Consultant/  # Template for client consulting engagements
├── .gemini/                      # Agent protocol (works with Gemini CLI)
│   ├── Skills/                   # 17 skill modules loaded on demand
│   ├── commands/                 # 15 slash commands for common workflows
│   ├── hooks/                    # 8 lifecycle hooks (secrets, lint, tests, audit)
│   ├── rules/                    # Hard guardrails by language and domain
│   ├── memory/                   # Cross-session persistent state
│   └── settings.json             # Hook wiring + MCP server config
├── rules/
│   ├── lessons.md                # Agent self-improvement log
│   └── audit.log                 # Append-only hook audit trail
└── GEMINI.md                     # Root agent instructions
```

---

## Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/sammccain1/MWP-Folder-Structures.git
cd MWP-Folder-Structures
```

### 2. Start a new project

Use the `/new-project` or `/new-client` command from within a Gemini CLI session, or copy manually:

```bash
# Developer project (ML, pipelines, web apps, maps, simulations)
cp -r Folder-Structure-Developer/ ../my-project/
cd ../my-project

# Consulting engagement (client work, deliverables, proposals)
cp -r Folder-Structure-Consultant/ ../client-project/
cd ../client-project
```

> **Important:** Copy the workspace template, but keep the `.gemini/` directory in the MWP root — it is the shared agent protocol used by all projects cloned from this repo. Reference it from your project or symlink as needed.

### 3. Run standup at the start of every session

```
/standup
```

This orients the agent: reads task.md, loads per-client memory (Consultant), reviews recent commits, checks test status, and surfaces relevant lessons and standing decisions.

### 4. End every session with sync-memory

```
/sync-memory
```

Writes session state to `.gemini/memory/` and commits a checkpoint so the next session starts with full context.

---

## The `.gemini/` Protocol

### Skills — loaded on demand, not all at once

| Skill | Load When |
|---|---|
| `planner` | Multi-step planning, ADRs, architecture decisions |
| `code-review` | PR reviews, diff analysis |
| `debugger` | Bug reports, failing tests, unexpected behaviour |
| `refactorer` | Tech debt, deduplication, modernising legacy code |
| `doc-writer` | READMEs, API docs, changelogs, docstrings |
| `security-review` | Pre-delivery security sweeps, auth review |
| `e2e-testing` | Playwright tests, flaky test remediation |
| `ml-model` | Sklearn models, LOSO CV, model versioning |
| `data-pipeline` | ETL, scraping, scheduling, idempotency |
| `data-viz` | Matplotlib, ggplot2, Mapbox GL |
| `r-analysis` | toRvik, tidyverse, bracket simulation |
| `consultant-writer` | SOWs, proposals, status reports |
| `frontend-design` | Production-grade UI, design system |
| `ui-ux-design` | WCAG, user flows, Tailwind + shadcn scaffolding |
| `pen-testing` | OWASP Top 10, pre-delivery security assessment |
| `web-animation` | Remotion video production — see sub-skill map |

### Commands — slash commands for common workflows

| Command | Purpose |
|---|---|
| `/standup` | Session-start briefing — run this first, every time |
| `/sync-memory` | End-of-session state capture — run this last, every time |
| `/new-project` | Scaffold a Developer project from the template |
| `/new-client` | Onboard a new consulting engagement |
| `/checkpoint` | Mid-session save before risky operations |
| `/deploy` | Deployment workflow (Vercel, Docker, Supabase) |
| `/review` | Full pre-delivery quality gate |
| `/pr-review` | Structured pull request review |
| `/debug` | Autonomous bug fix workflow |
| `/db-migrate` | Safe database migration workflow |
| `/report` | Generate client status report |
| `/pen-test` | Security assessment before client handoff |
| `/hackathon` | Hackathon kickoff and delivery workflow |
| `/clean` | Workspace hygiene — remove build artifacts |
| `/add-rule` | Add a new guardrail to `.gemini/rules/` |

### Hooks — run automatically via `settings.json`

| Hook | Trigger | Purpose |
|---|---|---|
| `session-start.sh` | Session open | Print repo context, task status, recent commits |
| `secrets-check.sh` | Before every tool | Block leaked API keys and tokens |
| `pre-commit.sh` | Before shell commands | Git snapshot before destructive operations |
| `dependency-check.sh` | Before shell commands | Scan npm/pip for known CVEs |
| `post-tool.sh` | After every tool | Structured audit log entry |
| `lint-on-save.sh` | After file writes | Run ruff/tsc/shellcheck on changed files |
| `test-on-change.sh` | After file writes | Run pytest/npm test/testthat on src/ changes |
| `accessibility-check.sh` | After file writes | WCAG2AA check after UI changes |

### Rules — hard guardrails loaded at session start

`guardrails.md` · `api.md` · `database.md` · `frontend.md` · `python.md` · `r.md` · `typescript.md` · `sql.md`

---

## Primary Stack

| Layer | Technology |
|---|---|
| Languages | Python, TypeScript, R, SQL, Bash |
| Frontend | React, Next.js (App Router), Tailwind, shadcn |
| Backend | FastAPI, Node.js |
| Data | Pandas, NumPy, scikit-learn, Matplotlib, ggplot2 |
| Database | PostgreSQL, Supabase |
| Infra | Docker, Vercel, Anaconda, Git |

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for how to add skills, commands, hooks, and rules.

---

## License

MIT — see [LICENSE](./LICENSE).
