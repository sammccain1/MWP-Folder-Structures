# Planning/workflows/specs/ — Context

This is **Stage 2** of the agentic build pipeline. See `../CONTEXT.md` for the full overview.

---

## Purpose

Translate an approved brief into a **technical plan** — the complete blueprint for what will
be built, how it will be structured, and where files will live. No code is written until the
spec is approved by the user.

---

## When to Create a Spec

After the brief in `briefs/` has been confirmed by the user. Reference the source brief by
filename at the top of every spec.

---

## Spec Template

```markdown
# [Project/Feature Name] — Spec
Date: YYYY-MM-DD
Source Brief: briefs/YYYY-MM-DD_name-brief.md
Status: DRAFT | APPROVED

## Overview
One paragraph technical summary of what will be built.

## Architecture
- Stack choices (language, framework, libraries)
- System diagram or data flow description
- Key dependencies and why they were chosen

## Data Model
- Schema definitions (tables, fields, types, constraints)
- Relationships between entities

## API Contract
- Endpoints (method, path, request, response shapes)
- Auth requirements per endpoint

## Component / Module Breakdown
- List of files to be created
- Responsibility of each file
- Target path in src/ (reference output-guide/CONTEXT.md)

## Task Checklist
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## Open Questions
Questions that need user input before or during build.

## Out of Scope
Anything explicitly excluded from this build pass.
```

---

## File Naming

```
YYYY-MM-DD_project-name-spec.md

Examples:
  2026-04-07_election-map-spec.md
  2026-04-07_supabase-auth-spec.md
```

---

## Approval Gate

**The spec must be approved by the user before Stage 3 begins.**
Set `Status: APPROVED` in the spec header when the user confirms.
Do not begin `builds/` execution on a DRAFT spec.
