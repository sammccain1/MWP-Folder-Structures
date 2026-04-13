---
name: add-rule
description: Workflow command scaffold for adding a new rule file to .gemini/rules/. Includes standard templates.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /add-rule

Use this workflow to add a new set of guardrails to the MWP `.gemini/rules/` system.

## Goal

Create a focused markdown rule file that enforces safety, patterns, and anti-patterns for a specific stack component, and wire it into the main agent context.

## Standard Rule Template

When generating the rule file in `.gemini/rules/<domain>.md`, use this exact schema:

```markdown
# [Domain] Rules

Stack: [Versions/Tools, e.g., TypeScript 5+, React 18]

---

## Safety — Non-Negotiable
- [Rule 1: e.g. Never use 'any']
- [Rule 2]

## Core Patterns
- **[Pattern Name]:** [Short description]
  ```language
  // ✅ DO:
  [correct code]

  // ❌ DON'T:
  [incorrect code]
  ```

## Anti-Patterns
- [Mistake to avoid and why]

## Rules Summary

| Rule | Rationale |
|---|---|
| Rule 1 summary | Why it exists |
| Rule 2 summary | Why it exists |
```

## Setup Sequence

1. Verify the domain isn't already covered in `rules/`.
2. Generate `.gemini/rules/<domain>.md` using the template above.
3. Update `.gemini/rules/CONTEXT.md` index.
4. Update `GEMINI.md` and `CLAUDE.md` root indices.
5. Create a `chore: add <domain> rules` git commit.