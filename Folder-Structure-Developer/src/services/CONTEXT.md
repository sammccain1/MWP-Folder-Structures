# src/services/ — Business Logic & API Layer

You are in the **services directory**. All business logic, third-party API clients, and data access routines live here. 

## What Belongs Here

- **API Clients** — wrapped clients for external APIs (e.g., `openai_client.py` or `kenpom_api.ts`)
- **Business Logic** — core application logic that shouldn't be tied to UI components
- **Database Access** — generic data fetching, ORM queries, Supabase clients
- **Side Effects** — functions that mutate state, write to disks, or call networks

## What Does NOT Belong Here

- UI Components — never import React/Next.js components into a service
- Pure functions/utilities — simple formatters belong in `src/utils/`
- Express/FastAPI route definitions — those belong in `src/routes/` or `src/app/`

## Rules

- Services must be decoupled from the framework UI (e.g., no Next.js `useRouter` in a service)
- Dependency injection is preferred when configuring clients (pass config as args, don't hardcode)
- Throw typed errors (or return Option/Result patterns) so consumers can handle failures gracefully
- Test coverage for side-effect heavy logic is mandatory (≥80%)
