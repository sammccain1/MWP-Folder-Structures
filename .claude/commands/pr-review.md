---
name: pr-review
description: Structured pull request review workflow. Reviews diffs against MWP principles — security, immutability, test coverage, naming, and stack-specific anti-patterns. Loads code-review and security-review skills automatically.
allowed_tools: ["Bash", "Read", "Grep", "Glob"]
---

# /pr-review

Structured PR review against MWP standards. Load this command, provide a branch or diff, and the agent conducts a full review.

## Skills to Load

Before reviewing, load:
- `.gemini/agents/skills/code-review/SKILL.md`
- `.gemini/agents/skills/security-review/SKILL.md`

## Getting the Diff

```bash
# Review against main
git diff main...HEAD

# Review specific files
git diff main...HEAD -- src/ ops/

# See what files changed
git diff main...HEAD --name-only
```

## Review Checklist

### Security (block merge if any fail)
- [ ] No hardcoded secrets, API keys, or tokens
- [ ] All SQL uses parameterized queries — no f-strings or `.format()` in queries
- [ ] User inputs validated at API boundary (Pydantic / Zod)
- [ ] Auth checks present on all protected routes
- [ ] No PII logged to console or written to unencrypted storage

### Correctness
- [ ] Tests added or updated for all changed logic
- [ ] Coverage ≥ 80% on `src/services/` and `src/utils/`
- [ ] No Pandas in-place mutations (`df.drop(inplace=True)` → flag it)
- [ ] TypeScript strict mode — no `any` without justification comment
- [ ] Async functions properly awaited — no floating promises

### Architecture
- [ ] No `components/` importing from `services/` (dependency direction violation)
- [ ] No business logic in React components — belongs in `services/`
- [ ] DB schema changes have a corresponding migration file
- [ ] New directories include a `CONTEXT.md`

### Naming & Conventions
- [ ] Python: `snake_case` functions/variables, `PascalCase` classes
- [ ] TypeScript: `camelCase` functions, `PascalCase` components/types
- [ ] Files follow naming convention for their type (see GEMINI.md)
- [ ] Branch name follows convention: `feat/`, `fix/`, `chore/`, `data/`

### Commit Quality
- [ ] Conventional commits: `fix:`, `feat:`, `chore:`, `docs:`, `test:`
- [ ] No `WIP`, `temp`, or `asdf` commit messages in the PR
- [ ] Each commit is coherent — not a mix of unrelated changes

## Severity Levels

| Level | Label | Action |
|---|---|---| 
| 🔴 Block | Security violation, data loss risk, broken tests | Must fix before merge |
| 🟡 Required | Convention violation, missing test, anti-pattern | Fix before merge |
| 🟢 Suggest | Style improvement, elegance, optional refactor | Address or document why not |

## Output Format

```
## PR Review — [branch name] → main

### Summary
[2-3 sentences: what does this PR do, overall quality assessment]

### 🔴 Blockers
- [file:line] — [issue] — [fix]

### 🟡 Required Changes
- [file:line] — [issue] — [fix]

### 🟢 Suggestions
- [file:line] — [suggestion]

### Verdict
[ ] Approve  [ ] Request Changes  [ ] Needs Discussion
```

## Notes

- Be specific: always include file path and line number
- Assume positive intent — explain *why* something is a problem, not just that it is
- If a pattern appears more than twice in the PR, flag it once with "this pattern appears N times"