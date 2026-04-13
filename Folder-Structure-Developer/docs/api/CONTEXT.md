# docs/api/ — Context

This directory contains standalone API documentation and data contracts.

## Purpose

When APIs are built (either in `src/api/` for FastAPI or `src/app/api/` for Next.js), the code serves as the implementation. However, for a fully documented backend, API specifications or endpoint templates are stored here.

## Rules

- Do not write code here. Link to `src/` to point agents/developers to the actual router handlers.
- Document the schema explicitly so frontend clients can adapt correctly.
- Use `api-endpoint-template.md` when designing a new route before it's coded.
