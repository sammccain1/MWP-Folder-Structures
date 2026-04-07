---
name: git-workflow
description: Git branching strategy, commit conventions, PR workflow, rebase vs merge decisions, and conflict resolution. Load when starting a new feature, reviewing a PR, resolving conflicts, or establishing team git conventions.
---

# Git Workflow Skill

Branching strategy, commit conventions, and PR workflow for Sam's solo and team projects.

---

## Branch Naming (from GEMINI.md)

```bash
feat/short-description      # new feature
fix/short-description       # bug fix
data/dataset-name           # data branches (ML/sports)
chore/short-description     # maintenance, deps, config
docs/short-description      # documentation only
refactor/short-description  # code restructuring, no behavior change

# Examples:
feat/political-map-layer
fix/pipeline-null-error
data/mm-2026-season
chore/update-gemini-hooks
```

---

## Commit Message Format

```
<type>(<scope>): <short summary>

<optional longer description>

<optional: Breaking Change or Issue reference>
```

**Types:** `feat` · `fix` · `chore` · `docs` · `refactor` · `test` · `perf` · `style`

**Scope examples:** `api` · `auth` · `map` · `pipeline` · `model` · `ui` · `gemini`

```bash
# ✅ Good commit messages
feat(map): add county-level choropleth layer for 2024 results
fix(pipeline): handle null FIPS codes in election data join
chore(gemini): update hook exit codes to advisory-only
docs: add 2026-04-07 changelog entry

# ❌ Bad commit messages
fix bug
update stuff
wip
```

**Rules:**
- Summary line max **72 characters**
- Use imperative mood: "add X", "fix Y", "remove Z" (not "added" or "adding")
- Reference issues when applicable: `fix(auth): handle expired tokens (#42)`

---

## Branching Strategy

### Solo Projects
```bash
# Work directly on feature branches off main
git checkout -b feat/election-map-2026
# ... work ...
git push origin feat/election-map-2026
# Merge via PR or directly after self-review
git checkout main && git merge --no-ff feat/election-map-2026
git branch -d feat/election-map-2026
```

### Team Projects
```
main          ← production, always deployable
  └── feat/   ← feature branches, open PRs against main
  └── fix/    ← hotfix branches
```

- Never commit directly to `main`
- PRs require at least self-review before merge (or team review)
- Delete branches after merge

---

## Rebase vs Merge

| Situation | Use |
|---|---|
| Keeping a feature branch up to date with `main` | `git rebase main` |
| Integrating a finished feature into `main` | `git merge --no-ff` (preserves branch history) |
| Cleaning up messy WIP commits before PR | `git rebase -i HEAD~N` (interactive squash) |
| Never | `git push --force` to `main` |

```bash
# Update feature branch with latest main (rebase)
git fetch origin
git rebase origin/main

# If conflicts, resolve then:
git add .
git rebase --continue

# Interactive squash — condense 5 WIP commits into 1 clean commit
git rebase -i HEAD~5
# In editor: change 'pick' to 'squash' (s) for commits to merge
```

---

## Pre-PR Checklist

```
[ ] Branch is up to date with main (git rebase origin/main)
[ ] All commits follow message conventions
[ ] No debug code, console.logs, or commented-out blocks
[ ] secrets-check passes (no tokens/keys in diff)
[ ] lint-on-save passes (ruff / tsc / shellcheck)
[ ] Tests pass (pytest / npm test)
[ ] .env.example updated if new env vars were added
[ ] PR description explains what and why (not just what)
```

---

## Conflict Resolution

```bash
# 1. See what's conflicting
git status

# 2. Open conflicting file — look for conflict markers
<<<<<<< HEAD
  your version
=======
  incoming version
>>>>>>> feat/other-branch

# 3. Edit to resolve — remove all conflict markers
# 4. Stage the resolved file
git add resolved-file.ts

# 5. Continue merge/rebase
git rebase --continue   # if rebasing
git merge --continue    # if merging (rare)
```

**Rule:** Always run tests after resolving conflicts — merge resolutions introduce bugs more often than raw code changes.

---

## Useful Commands

```bash
# See what changed since last commit
git diff HEAD

# Stage specific files (not everything)
git add src/services/api.ts src/tests/api.test.ts

# Amend the last commit (before push)
git commit --amend --no-edit

# Undo last commit but keep changes staged
git reset --soft HEAD~1

# Stash work-in-progress
git stash push -m "wip: map layer color fixes"
git stash pop

# Find which commit introduced a bug
git bisect start
git bisect bad HEAD
git bisect good v1.0.0
# git will checkout midpoints — test each and mark good/bad
```

---

## When to Load This Skill

- Starting a new feature branch
- Resolving merge conflicts
- Cleaning up commits before opening a PR
- Establishing git conventions for a new team project
- Recovering from a botched merge or accidental commit
