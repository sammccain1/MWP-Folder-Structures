# Planning/architecture/decisions/ — Context

This directory contains Architecture Decision Records (ADRs).

## Purpose

ADRs capture major technical choices, the context behind them, and their consequences. They ensure future developers (and AI agents) understand *why* the stack looks the way it does.

## When to write an ADR

Write an ADR when:
- Establishing the core project stack (e.g., choosing Next.js over Vite)
- Selecting a primary database pattern (e.g., Supabase vs raw PostgreSQL)
- Defining a new data orchestration pipeline (e.g., Mage vs Airflow)
- Adding a major third-party dependency.

Do not write ADRs for trivial or reversible implementation details.

## Naming Convention

`ADR-[number]-[kebab-case-title].md`

Examples:
- `ADR-001-use-supabase-for-auth.md`
- `ADR-002-nextjs-app-router.md`

Use the `ADR-000-template.md` when creating a new record.
