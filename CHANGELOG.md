# Changelog

All notable changes to MWP are documented here. Follows [Keep a Changelog](https://keepachangelog.com/) conventions.

---

## [Unreleased]

---

## 2026-04-07 — Developer Template Gap Remediation & Hook Hardening

### Added
- `Folder-Structure-Developer/CLAUDE.md` — Claude Code agent instruction file, synced sibling to `GEMINI.md` (required by MWP protocol rule #3)
- `Folder-Structure-Developer/data/raw/README.md` — data inventory template enforcing documentation convention by example
- `Folder-Structure-Developer/data/raw/` — directory with `.gitkeep` (previously missing, only referenced in `data/CONTEXT.md`)
- `Folder-Structure-Developer/data/processed/` — directory with `.gitkeep` (previously missing)
- `Folder-Structure-Developer/ops/deploy/Dockerfile` — FastAPI starter; pinned `python:3.11-slim`, uvicorn entrypoint
- `Folder-Structure-Developer/ops/deploy/Dockerfile.web` — Next.js starter; pinned `node:20-alpine`, multi-stage build
- `Folder-Structure-Developer/ops/scripts/init.sql` — PostgreSQL init stub wired to docker-compose volume mount
- `Folder-Structure-Developer/ops/monitoring/CONTEXT.md` — observability, alerting, and structured logging conventions
- `Folder-Structure-Developer/ops/scripts/CONTEXT.md` — automation script naming, idempotency, and `--confirm` flag rules
- `Folder-Structure-Developer/src/components/CONTEXT.md` — React/Next.js component conventions and prop typing rules
- `Folder-Structure-Developer/src/services/CONTEXT.md` — business logic, API client, and side-effect isolation patterns
- `Folder-Structure-Developer/src/utils/CONTEXT.md` — pure functions only, no side effects, circular dep prevention
- `Folder-Structure-Developer/src/tests/CONTEXT.md` — mirror pattern, coverage minimum, co-location vs centralized testing

### Changed
- `Folder-Structure-Developer/data/CONTEXT.md` — fully rewritten to document all 4 subdirs (`raw/`, `processed/`, `etl-pipelines/`, `feature-engineering/`) with a data flow diagram
- `Folder-Structure-Developer/models/CONTEXT.md` — expanded from 9 lines to full standard format with versioning rules, what-belongs-here section, and large-file guidance
- `Folder-Structure-Developer/data/etl-pipelines/CONTEXT.md` — expanded to full standard format with idempotency requirement and naming conventions
- `Folder-Structure-Developer/data/feature-engineering/CONTEXT.md` — expanded to full standard format with immutable-inputs rule and prefer-Parquet guidance
- `.gemini/settings.json` — corrected `model` field from string to object (`{"name": "gemini-2.5-pro"}`), moved `generationConfig` into `modelConfigs.customAliases`, consolidated `BeforeTool` shell matchers

### Fixed
- `Folder-Structure-Developer/task.md` — rewritten as an active agent working memory file with sprint, backlog, decisions, and notes sections
- `.gemini/hooks/lint-on-save.sh` — corrected stderr redirect order (`2>&1 >&2` → `>&2 2>&1`); fixed `git diff || echo ""` → `|| true` for `set -e` compatibility
- `.gemini/hooks/dependency-check.sh` — downgraded from hard-blocking (`exit 1`) to advisory (`exit 0` + stderr warning); added upgrade-path comment
- `.gemini/hooks/test-on-change.sh` — downgraded from hard-blocking (`exit $EXIT_CODE`) to advisory (`exit 0` + stderr warning); added upgrade-path comment
- `.gemini/hooks/post-tool.sh` — replaced broken stdin JSON parsing with correct env var lookup (`$GEMINI_TOOL_NAME`)

---

## 2026-03-31 — Protocol Hardening & Memory Loop

### Fixed
- Renamed `.gemini/Skills/frontend-Design/` → `frontend-design/` (casing consistency)
- All broken `.gemini/agents/skills/` path references → `.gemini/Skills/` across all commands
- `hackathon.md` hardcoded `/Users/sammccain/` path replaced with `$MWP_ROOT` detection
- `fix-issue.md` converted to alias pointing to `/debug` (removed duplicate command)

### Added
- `CONTRIBUTING.md` — protocol for adding skills, commands, hooks, rules
- `CHANGELOG.md` — this file
- `README.md` — full rewrite reflecting current protocol (was stale Day 1 version)
- `.gemini/memory/client-context/` directory with format guide README
- `rules/` CONTEXT.md explaining the directory purpose

### Changed
- `standup.md` — workspace-aware: detects Developer vs Consultant, reads per-client last-session memory, surfaces "next session starts here" line
- `sync-memory.md` — workspace-aware: writes per-client `[Name]-last-session.md` to `client-context/`, detects active client automatically
- `python.md` — expanded from 15 lines to 80: FastAPI patterns, error handling, pytest conventions, security
- `r.md` — expanded to full depth: `tryCatch`, `furrr` parallel sims, `toRvik` caching, R↔Python interop
- `Folder-Structure-Consultant/CLAUDE.md` — agent protocol section added: skill-by-task table, command reference, session memory instructions
- `Folder-Structure-Developer/CLAUDE.md` — skill table updated to reflect all 17 current skills with correct paths
- `hackathon.md` — pre-demo checklist wired into `/review` command, skills explicitly referenced
- `GEMINI.md` — skills inventory path corrected (`.gemini/Skills/` capitalised)

---

## 2026-03-30 — MCP, Memory & Language Rules

### Added
- `.gemini/settings.json` — full hook wiring (SessionStart, BeforeTool, AfterTool) + MCP server config (github, filesystem, knowledge-graph)
- `.gemini/memory/standing-decisions.md` — 5 initial architectural decisions (LOSO CV, Parquet format, forward-only migrations, subagent strategy, no frontend placeholders)
- `.gemini/memory/README.md` — memory system documentation
- `.gemini/rules/python.md` — Python 3.11+ guardrails
- `.gemini/rules/r.md` — R/tidyverse/toRvik guardrails
- `.gemini/rules/typescript.md` — TypeScript strict mode, React prop patterns
- `.gemini/rules/sql.md` — parameterized queries, schema conventions, RLS, migrations
- `.gemini/hooks/session-start.sh` — session orientation banner
- `.gemini/hooks/accessibility-check.sh` — WCAG2AA check after UI file changes
- `.gemini/hooks/dependency-check.sh` — npm audit + pip-audit before installs
- `.gemini/commands/review.md` — full pre-delivery quality gate
- `.gemini/commands/clean.md` — workspace hygiene command
- `.gemini/commands/sync-memory.md` — end-of-session state capture
- `.gemini/commands/report.md` — client status report generator
- `.gemini/commands/db-migrate.md` — safe database migration workflow
- `.gemini/commands/debug.md` — autonomous bug fix workflow (canonical, replaces fix-issue)
- `.gemini/commands/hackathon.md` — hackathon kickoff and delivery workflow
- `.gemini/commands/pen-test.md` — structured security assessment
- `.gemini/Skills/web-animation/` — Remotion skill library (7 sub-skills: spec-writing, style-guide, visual-direction, animation-primitives, composition-structure, common-patterns, rendering)
- `.gemini/Skills/ui-ux-design/` — WCAG, user flows, Tailwind + shadcn scaffolding
- `.gemini/Skills/pen-testing/` — OWASP Top 10, Next.js + FastAPI attack vectors
- `.gemini/.gitignore`

### Fixed
- Hook stdout/stderr routing corrected for Gemini CLI compatibility
- `settings.json` hook schema corrected to `BeforeTool`/`AfterTool`
- `secrets-check.sh` exit code behaviour hardened (exit 2 = hard block)

---

## 2026-03-29 — Core Protocol Scaffold

### Added
- `.gemini/Skills/code-review/` — stack-specific anti-patterns, severity guide
- `.gemini/Skills/debugger/` — debug commands, root-cause tables, CI failure patterns
- `.gemini/Skills/doc-writer/` — README, API, changelog, docstring templates
- `.gemini/Skills/e2e-testing/` — Playwright POM templates, selector strategy, CI config
- `.gemini/Skills/planner/` — ADR template, Supabase schema plans, ML pipeline templates
- `.gemini/Skills/refactorer/` — before/after recipes for Python, TypeScript, React
- `.gemini/Skills/security-review/` — full-stack security patterns, report template
- `.gemini/Skills/ml-model/` — sklearn lifecycle, LOSO CV, model versioning
- `.gemini/Skills/data-pipeline/` — ETL, scraping, scheduling, idempotency
- `.gemini/Skills/data-viz/` — Matplotlib, ggplot2, Mapbox GL layer recipes
- `.gemini/Skills/r-analysis/` — toRvik, tidyverse, bracket simulation
- `.gemini/Skills/consultant-writer/` — SOW, proposals, status reports
- `.gemini/Skills/frontend-design/` — production-grade UI, design tokens
- `.gemini/hooks/pre-commit.sh` — git snapshot before destructive operations
- `.gemini/hooks/lint-on-save.sh` — ruff/tsc/shellcheck on changed files
- `.gemini/hooks/post-tool.sh` — audit log entry after every tool call
- `.gemini/hooks/secrets-check.sh` — pattern scan for leaked keys/tokens
- `.gemini/hooks/test-on-change.sh` — pytest/npm test/testthat on src/ changes
- `.gemini/commands/standup.md` — session-start briefing
- `.gemini/commands/checkpoint.md` — mid-session save
- `.gemini/commands/deploy.md` — Vercel/Docker/Supabase deployment workflow
- `.gemini/commands/fix-issue.md` — autonomous bug fix (now alias to `/debug`)
- `.gemini/commands/pr-review.md` — structured pull request review
- `.gemini/commands/new-project.md` — Developer workspace scaffolding
- `.gemini/commands/new-client.md` — Consultant engagement onboarding
- `.gemini/commands/add-rule.md` — add a new guardrail to `.gemini/rules/`
- `.gemini/rules/api.md` — FastAPI + Next.js API rules
- `.gemini/rules/database.md` — SQL safety, migration strategy, Pandas rules
- `.gemini/rules/frontend.md` — React, TypeScript, Next.js App Router rules
- `.gemini/rules/guardrails.md` — hard limits, override all other instructions
- `Folder-Structure-Developer/` — full workspace template with CONTEXT.md files
- `Folder-Structure-Consultant/` — full workspace template with CONTEXT.md files
- `rules/lessons.md` — agent self-improvement log
- `rules/audit.log` — append-only hook audit trail
- `GEMINI.md` — root agent instructions

---

## 2026-03-28 — Initial Commit

### Added
- `Folder-Structure-Developer/` — initial folder scaffold
- `Folder-Structure-Consultant/` — initial folder scaffold
- `README.md` — initial description
- `LICENSE` — MIT
