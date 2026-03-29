# src/ — Source Code

You are in the **source code directory** of this project. All production code lives here.

## Subdirectory Guide

| Directory | Purpose |
|---|---|
| `components/` | UI components — React/Next.js, always `PascalCase.tsx`, typed with explicit Props interfaces |
| `services/` | Business logic, API calls, data access. Keep side effects isolated here. |
| `utils/` | Shared helper functions, formatters, constants. Pure functions only — no side effects. |
| `tests/` | Unit and integration tests. Mirror the directory structure of what you're testing. |

## Rules for This Directory

- Never import from `components/` inside `services/` — keep the dependency direction clean
- All TypeScript files must use strict mode
- Test coverage must be ≥ 80% for any `services/` or `utils/` module
- Python scripts and notebooks belong here (or in a `notebooks/` subdirectory) — not in `ops/`
- Never commit API keys, tokens, or secrets — use `.env` with `.gitignore`
