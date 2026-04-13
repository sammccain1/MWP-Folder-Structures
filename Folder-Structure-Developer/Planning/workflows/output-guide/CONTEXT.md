# Planning/workflows/output-guide/ — Context

This directory represents **Stage 4** of the agentic build pipeline.
See `../CONTEXT.md` for the full overview.

---

## Purpose

The output guide tells the agent **where in `src/` (or other production folders) a completed deliverable should go.** 

Never write in-progress work directly to `src/`. Once a build is marked `COMPLETE` in `builds/`, consult this table and place the files exactly where they belong.

---

## Output Routing Rules

Use this table to route your final code.

| Deliverable Type | Target Directory | 
|---|---|
| React / Next.js UI Component | `src/components/` (and subdirectories like `ui/` or `layout/`) |
| Business Logic / Data Fetching | `src/services/` |
| Pure Functions / Helpers | `src/utils/` |
| Automated Tests | `src/tests/` |
| Shared TypeScript Types | `src/types/` |
| Custom React Hooks | `src/hooks/` |
| API Route (Next.js) | `src/app/api/` |
| API Route (FastAPI) | `src/api/` (or `src/routers/`) |
| ETL / Data Pipeline (dev) | `data/etl-pipelines/` |
| Production / Scheduled Script | `ops/scripts/` |
| ML Training / Exploration | `notebooks/` |
| ML Training / Inference (prod) | `src/services/` |
| Serialized Model Output | `models/` |

---

## Execution

When writing code to its final destination, you must follow the coding standards and guardrails loaded in the `.gemini/rules/` directory (e.g. `typescript.md`, `reactjs.md`, `python.md`).
