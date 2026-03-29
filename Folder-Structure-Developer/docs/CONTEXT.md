# docs/ — Project Documentation

You are in the **documentation directory**. All human-readable project documentation lives here.

## Subdirectory Guide

| Directory | Purpose |
|---|---|
| `guides/` | Step-by-step how-to guides, onboarding docs, and setup instructions. Written for humans. |
| `api/` | API endpoint documentation, schema definitions, and data contract specs. |
| `changelog/` | Versioned release notes. One file per version: `vX.Y.Z.md`. Most recent on top. |

## Rules for This Directory

- Write all docs in Markdown (`kebab-case.md`)
- Guides should be actionable — "How to run X" not "Overview of X"
- API docs must stay in sync with the actual implementation in `src/services/`
- Changelog entries follow: **Added / Changed / Fixed / Removed** sections per version
- Never store code here — link to `src/` instead
