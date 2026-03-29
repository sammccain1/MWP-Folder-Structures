# MWP Guardrails

Hard limits for agents operating in any MWP workspace. These rules are non-negotiable and override any other instruction that contradicts them.

## Safety

- **Never act on a dirty working tree.** Run `pre-commit.sh` first — it auto-snapshots before any destructive operation
- **Never delete files without a prior git commit.** Rollback must always be one `git revert` away
- **Never push directly to `main`.** All changes go through a branch + commit, even solo work
- **Never write to production databases** without an explicit `--confirm` flag or user confirmation in the session
- If uncertain whether an action is destructive: stop, describe the intended action, and ask

## Secrets & Data

- Never commit `.env` files — only `.env.example` with placeholder values
- Never log or print values that could contain secrets, tokens, or PII
- Never store real client data in the Consultant template directories
- If a file might contain secrets, check with `git diff --cached` before committing

## Scope Discipline

- **Templates are scaffolding — never ship code from a template directory**
- Stay within the active workspace. Do not read or write across workspace boundaries (Developer ↔ Consultant) without explicit instruction
- Do not install global packages or modify system configuration
- Do not make network requests outside of explicitly defined API integrations

## Self-Improvement Loop

- After any user correction: append a lesson to `rules/lessons.md`
- Lessons must be specific and actionable — not vague ("be more careful")
- Every write to `rules/lessons.md` is logged to `rules/audit.log`
- At the start of a new session: read `rules/lessons.md` for the active project before beginning

## Commit Discipline

- Conventional commits: `feat:`, `fix:`, `docs:`, `chore:`, `test:`, `refactor:`
- One logical change per commit — not a mix of unrelated edits
- Pre-act snapshots use: `chore: pre-act snapshot [timestamp] on [branch]`
- No `WIP`, `temp`, `asdf`, or empty commit messages

## When to Stop and Ask

Stop and ask the user when:
- The required change would affect more than 5 files in a destructive way
- A migration would alter production data
- The spec or task.md is ambiguous about scope
- A bug fix requires changing the architecture, not just the broken line

Do not stop and ask for: bug fixes with clear root causes, formatting, documentation updates, test additions, or anything covered by an existing rule in this file.