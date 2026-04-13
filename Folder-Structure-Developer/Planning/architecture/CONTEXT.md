# Planning/architecture/ — Context

This directory is the single source of truth for the project's technical design, system flow, and architectural evolution.

---

## Subdirectory Guide

| Directory | Purpose |
|---|---|
| `decisions/` | Architecture Decision Records (ADRs). Document the *why* behind major choices. |
| `diagrams/` | System architecture patterns, ER (Entity-Relationship) diagrams, and data flow maps. |

---

## General Rules

- **Use Mermaid Markdown:** Prefer `.md` files containing Mermaid diagrams over binary images like PNG/JPEG, so the architecture is easily diffable in version control.
- **Maintain the Stack Doc:** When initializing a project, generate a `stack-decisions.md` in this folder documenting the overarching stack before diving into individual components.
- **Agent Memory:** Agents use this specific folder to understand how the system fits together before modifying individual modules in `src/`.
