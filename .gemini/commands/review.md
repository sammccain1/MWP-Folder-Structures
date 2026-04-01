---
name: review
description: Run a full pre-delivery code review pass. Executes secrets check, dependency audit, lint, tests, and accessibility check in sequence. Use before any client handoff, PR merge, or hackathon submission.
allowed_tools: ["Bash", "Read"]
---

# /review

Full pre-delivery quality gate. Run this before any client handoff, PR, or hackathon submission.

## Step 1 — Secrets & Dependencies

```bash
bash .gemini/hooks/secrets-check.sh
bash .gemini/hooks/dependency-check.sh
```

Expected: both exit 0. If either fails, fix before continuing.

## Step 2 — Lint

```bash
# Python
ruff check src/ --fix

# TypeScript / Next.js
npm run lint -- --fix
```

## Step 3 — Tests

```bash
# Python
pytest --tb=short -q

# TypeScript
npm run test -- --passWithNoTests

# R
Rscript -e "testthat::test_dir('tests/')"
```

## Step 4 — Build (frontend only)

```bash
npm run build
# Expect: no type errors, no build failures
```

## Step 5 — Accessibility (if UI exists)

```bash
# Dev server must be running
pa11y http://localhost:3000 --standard WCAG2AA --reporter cli
```

## Step 6 — Security Quick-Scan

Work through the OWASP manual checklist in `.gemini/Skills/pen-testing/SKILL.md`:
- [ ] A01: Access control tested
- [ ] A03: SQLi + XSS inputs tested
- [ ] A05: CSP and CORS headers verified
- [ ] A07: Login rate limiting verified

## Step 7 — Final Sign-off

```bash
git diff --stat HEAD  # confirm only expected files changed
git log --oneline -5  # confirm commits are clean and atomic
```

- [ ] All tests green
- [ ] No secrets in diff
- [ ] Build passes
- [ ] Commit history is readable
- [ ] `task.md` marked complete
