# Planning/ — Pre-Implementation Planning

You are in the **planning directory**. All design and decision artifacts live here — written before code is written.

## Subdirectory Guide

| Directory | Purpose |
|---|---|
| `specs/` | Feature specs and PRDs. Answer: what are we building, why, and how will we know it works? |
| `decisions/` | Architecture Decision Records (ADRs). Document the *why* behind major technical choices. |
| `architecture/` | System diagrams, data flow maps, and high-level design docs. Use Mermaid or draw.io exports. |

## Rules for This Directory

- **Plan before you code.** No `src/` changes without a corresponding spec or ADR for non-trivial features.
- Specs use `kebab-case.md`: `feat-political-map.md`, `ml-model-design.md`
- ADRs follow the format: **Context / Decision / Consequences**
- Architecture diagrams should be version-controlled (Mermaid in `.md` preferred over binary image files)
- This directory is the agent's working memory for design — keep it updated as decisions evolve
- `task.md` at the project root links back to specs in this directory for traceability
