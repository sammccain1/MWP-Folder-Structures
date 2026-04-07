# Planning/ — Pre-Implementation Planning

You are in the **planning directory**. All design and decision artifacts live here —
written before and during implementation. This directory is the agent's working memory.

---

## Subdirectory Guide

| Directory | Purpose |
|---|---|
| `workflows/` | The **4-stage agentic build pipeline**: briefs → specs → builds → output-guide. Start here for every new feature or project. |
| `architecture/` | System diagrams, data flow maps, high-level design docs, and Architecture Decision Records (ADRs). |

---

## The Build Pipeline (`workflows/`)

Every new thing built in this project follows this pipeline — in order, no skipping:

```
workflows/briefs/       → What to build (user intent, plain language)
workflows/specs/        → How to build it (technical plan, approved before coding)
workflows/builds/       → Execution log (progress, decisions, blockers)
workflows/output-guide/ → Route output to the correct location in src/
```

See `workflows/CONTEXT.md` for full pipeline documentation.

---

## Architecture (`architecture/`)

- `architecture/decisions/` — Architecture Decision Records (ADRs). Written when a
  major technical choice is made. See `architecture/decisions/CONTEXT.md` for the ADR
  format and naming convention.
- `architecture/diagrams/` — System diagrams, ER diagrams, data flow maps.
  Prefer Mermaid (`.md`) over binary image files for version control compatibility.

---

## Rules

- **Plan before you code.** No `src/` changes without a brief + approved spec for
  non-trivial features.
- All planning docs use `kebab-case.md` naming.
- ADRs follow **Status / Context / Decision / Consequences** format.
- Keep build logs updated during implementation — they are the session resume point.
- `task.md` at the project root links back to the active spec for traceability.
