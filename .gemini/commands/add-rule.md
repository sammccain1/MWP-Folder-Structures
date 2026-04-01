---
name: add-rule
description: Workflow command scaffold for adding a new rule file to .gemini/rules/. Use when a new language, framework, or domain requires explicit guardrails.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /add-rule

Use this workflow to add a new set of guardrails to the MWP `.gemini/rules/` system.

## Goal

Create a focused markdown rule file that enforces safety, patterns, and anti-patterns for a specific stack component, and wire it into the main agent context.

## Suggested Sequence

1. Identify the new domain or language requiring rules (e.g., `go`, `docker`, `aws`, `terraform`).
2. Draft the rule file in `.gemini/rules/<domain>.md`.
   - Start with a list of "Never do X" statements (the most critical guardrails).
   - Add "Always do Y" for expected patterns.
   - Keep it concise. Agents read this on every session.
3. Update `GEMINI.md` and `CLAUDE.md`.
   - Add the new file to the "Agent Configuration" section in the root context files so it is actually loaded.
4. Stage and commit with message `feat: add <domain> rule set`.

## Notes

- Rule files are about *safety and constraints* (what not to do).
- Skill files (`.gemini/Skills/`) are about *capability* (how to do it). Keep the distinction clear.