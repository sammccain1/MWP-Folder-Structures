# .gemini/rules/ — Agent Guardrail Files

You are in the **rules directory** of the Gemini CLI configuration. This directory contains
static guardrail files — loaded by the agent at session start to enforce coding standards,
safety limits, and architectural patterns across all MWP projects.

Rules files are **read-only from the agent's perspective** during a session. To add or
modify rules, use the `/add-rule` command.

---

## Rules Index

### Core Safety
| File | Covers |
|---|---|
| `guardrails.md` | Hard limits — overrides all other instructions. Safety, secrets, scope discipline, commit hygiene, when to stop and ask. |

### Languages
| File | Covers |
|---|---|
| `python.md` | Python 3.11+, FastAPI, Pydantic v2, scikit-learn, pytest, LOSO CV, error handling |
| `typescript.md` | TypeScript 5+, strict mode, branded types, discriminated unions, Result pattern, React typing |
| `r.md` | R 4.3+, {targets} pipelines, {pointblank} validation, ggplot2, {furrr} parallel sims |
| `bash.md` | Shell scripts — `set -euo pipefail`, quoting, arrays, stderr/stdout separation, `--confirm` |

### Frameworks & Libraries
| File | Covers |
|---|---|
| `reactjs.md` | React 18 — hooks rules, `useEffect` cleanup, memoization, virtualization, error boundaries |
| `frontend.md` | Next.js App Router — Server vs Client components, TanStack Query, Zustand, Server Actions |
| `api.md` | FastAPI + Next.js route handlers — auth, Pydantic validation, rate limiting, CORS, timeouts |
| `pandas.md` | Pandas — no inplace, `.loc`/`.iloc`, vectorization, merge validation, Parquet preference |

### Infrastructure
| File | Covers |
|---|---|
| `database.md` | PostgreSQL + Supabase — async SQLAlchemy, connection pooling, migrations, indexes, RLS |
| `sql.md` | Raw SQL — parameterized queries, schema design, CTEs, window functions, EXPLAIN ANALYZE |
| `docker.md` | Dockerfiles — pinned tags, multi-stage builds, non-root user, `.dockerignore`, secrets |
| `git.md` | Git — commit format, branch naming, forbidden ops (no force-push to main), tagging |
| `css.md` | CSS — custom properties, CSS Modules, no inline styles, WCAG contrast, responsive units |

---

## Loading Order

All files in this directory are loaded by the Gemini CLI at session start as defined in
`settings.json`. The load order is:

1. `guardrails.md` — hard limits, always first
2. All other rule files — alphabetical, supplemental

---

## Adding a New Rule File

Use `/add-rule` and follow the standard format:

```markdown
# [Domain] Rules

Stack: [list the specific tools/versions this covers]

---

## [Section: e.g., Safety / Pattern / Anti-pattern]

[code examples with ✅ and ❌ annotations]

---

## Rules Summary

| Rule | Rationale |
|---|---|
| ... | ... |
```

After creating the file, update:
1. `GEMINI.md` → Agent Configuration table
2. `CLAUDE.md` → Agent Configuration table (keep in sync)
3. This `CONTEXT.md` → Rules Index table above
