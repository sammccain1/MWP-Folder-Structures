# Git Rules

Enforced conventions for all git operations across MWP projects.

---

## Commit Messages

Format: `<type>(<scope>): <summary>`

**Allowed types:**
| Type | Use when |
|---|---|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `chore` | Maintenance — deps, config, build |
| `docs` | Documentation only |
| `refactor` | Code restructure, no behavior change |
| `test` | Adding or updating tests |
| `perf` | Performance improvement |
| `style` | Formatting, whitespace (no logic change) |

**Rules:**
- Summary line: max **72 characters**, imperative mood ("add", not "added")
- No emoji in commit messages (keep logs machine-parseable)
- Reference issue/ticket numbers when applicable: `fix(auth): handle token expiry (#42)`

---

## Branch Naming

```
feat/short-description
fix/short-description
data/dataset-name
chore/short-description
docs/short-description
refactor/short-description
```

- `kebab-case` only — no underscores, no uppercase
- Max 50 characters for the description segment
- Never commit directly to `main` on team projects

---

## Forbidden Operations

```bash
# ❌ NEVER force-push to main
git push --force origin main

# ❌ NEVER commit secrets
git add .env
git commit -m "add env file"

# ❌ NEVER use WIP-style commit messages
git commit -m "wip"
git commit -m "fix"
git commit -m "asdf"

# ❌ NEVER commit generated files if they're in .gitignore
git add -f rules/audit.log
```

---

## Required Before Every Commit

1. Run `secrets-check` (or `git diff --cached | grep -E "sk-|AKIA|ghp_"`)
2. Confirm `.env` is not staged
3. Confirm `.gitignore` covers all generated/sensitive files

---

## Tagging

```bash
# Semantic versioning for template/library releases
git tag -a v1.0.0 -m "feat: initial stable MWP template release"
git push origin v1.0.0
```

Format: `vMAJOR.MINOR.PATCH`
- MAJOR: breaking changes to template structure or agent protocol
- MINOR: new skills, commands, or rules added
- PATCH: bug fixes, typos, clarifications
