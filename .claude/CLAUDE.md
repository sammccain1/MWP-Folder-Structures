# MWP-Folder-Structures — Claude Code Entry Point

This is the **MWP meta-repository** — a collection of agent-ready workspace templates, not a live project. You are working with *scaffolding*, not shipping code from here.

## Active Workspaces

| Template | Path | Use When |
|---|---|---|
| Developer | `Folder-Structure-Developer/` | ML, pipelines, web apps, maps, sports |
| Consultant | `Folder-Structure-Consultant/` | Kubrick client engagements |

Read the `CONTEXT.md` in the relevant workspace before acting. Never modify template directories as if they were live projects.

## Protocol Files

| File | Purpose |
|---|---|
| `.claude/commands/` | Slash commands for Claude Code — `/plan`, `/review`, `/fix`, `/deploy`, `/pr-review` |
| `.gemini/agents/skills/` | Skill modules — load on demand, not all at once |
| `.gemini/rules/` | Hard rules: `guardrails.md`, `api.md`, `database.md`, `frontend.md` |
| `rules/lessons.md` | Agent self-improvement log — read at session start, append after corrections |
| `rules/audit.log` | Append-only hook audit trail |

> Note: Skills and rules live in `.gemini/` (Gemini CLI is the primary agent runtime).
> `.claude/` commands are the Claude Code interface into the same protocol.
> When in doubt, `.gemini/rules/guardrails.md` is authoritative.

## Session Start Checklist

1. Read `rules/lessons.md` — apply any lessons relevant to the current task
2. Identify which workspace template is active (Developer or Consultant)
3. Read that workspace's `CONTEXT.md`
4. Check `task.md` at project root if one exists

## Subagent Strategy

Use subagents for any task that is:
- Research-heavy (market research, API exploration, dependency evaluation)
- Parallel (linting multiple files, generating multiple templates simultaneously)
- Context-expensive (deep dives that would bloat the main context window)

One task per subagent. Keep the main context window clean.

## Core Principles

1. Agent-First — delegate domain tasks to specialized agents via skills
2. Plan Before Execute — non-trivial tasks get a spec or ADR before code
3. Safety First — pre-commit hook runs before any destructive operation
4. Verify Before Done — prove it works, don't just say it's done
5. Lessons Loop — every correction becomes a rule in `rules/lessons.md`
