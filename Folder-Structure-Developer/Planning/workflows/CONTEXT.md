# Planning/workflows/ — Context

This directory defines the **4-stage agentic build pipeline** used to take a project idea
from raw input to production-ready code delivered into `src/`.

You are an AI agent. When a user begins a new build, route them through these stages **in
order**. Do not skip stages.

---

## Pipeline Overview

```
briefs/  →  specs/  →  builds/  →  output-guide/  →  src/
 (what)     (how)     (execute)    (route output)    (ships)
```

---

## Stages

### 1. `briefs/` — What to Build
The entry point. The user (or agent via CLI input) defines **what** they want to build.

- Capture the project intent, feature scope, and any constraints
- A brief is written in natural language — not code, not architecture
- Output: a `YYYY-MM-DD_project-name-brief.md` file saved to `briefs/`
- The brief becomes the source of truth for the spec

**Agent trigger:** "I want to build X" → write a brief file here

---

### 2. `specs/` — How to Build It
Translates the brief into a **technical plan**.

- Architecture decisions, technology choices, data flow diagrams
- File/folder scaffolding plan — what will be created and where
- API contracts, schema design, component hierarchy
- Output: a `YYYY-MM-DD_project-name-spec.md` file saved to `specs/`
- The spec is reviewed and approved before any code is written

**Agent trigger:** Brief approved → generate spec, wait for user sign-off

---

### 3. `builds/` — Execution
The agent executes the approved spec.

- All implementation work is logged here as a running build log
- Tracks tasks completed, decisions made during build, blockers hit
- Output: a `YYYY-MM-DD_project-name-build-log.md` saved to `builds/`
- Linked back to the originating spec

**Agent trigger:** Spec approved → build, logging progress to builds/

---

### 4. `output-guide/` — Where the Output Goes
Tells the agent **where inside `src/`** the completed deliverable should be placed.

- See `output-guide/CONTEXT.md` for routing rules
- Maps deliverable type (component, service, util, test, pipeline, model) → target path in `src/`
- Prevents the agent from placing output in the wrong location

**Agent trigger:** Build complete → consult output-guide before writing to src/

---

## Destination: `src/`

`src/` is the **production directory**. Everything in `src/` is what gets pushed to GitHub
and deployed. It is the only directory that ships.

- Never write experimental or in-progress code directly to `src/`
- Only route to `src/` after the build is complete and output-guide has been consulted
- `src/` subdirectory routing: see `output-guide/CONTEXT.md`

---

## File Naming

| Stage | Convention | Example |
|---|---|---|
| Brief | `YYYY-MM-DD_name-brief.md` | `2026-04-07_election-map-brief.md` |
| Spec | `YYYY-MM-DD_name-spec.md` | `2026-04-07_election-map-spec.md` |
| Build log | `YYYY-MM-DD_name-build-log.md` | `2026-04-07_election-map-build-log.md` |
