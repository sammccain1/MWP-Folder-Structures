# src/tests/ — Unit and Integration Tests

You are in the **tests directory**. All automated tests for the application source code live here.

## What Belongs Here

- **Unit Tests** — logic tests for files in `utils/` and `services/`
- **Component Tests** — React Testing Library and Jest tests for `components/`
- **Integration Tests** — API and DB tests that exercise multiple layers
- **Mocks & Fixtures** — Mock data, API stubs, and test helpers

## What Does NOT Belong Here

- **E2E Tests** — Playwright or Cypress tests typically live at the repository root `e2e/` or in a dedicated `ops/tests/` folder
- **Production Code** — do not put active logic here

## Rules

- **Mirror the structure**: Your test folder should mirror `src/`. For example, `src/services/api.ts` should be tested in `src/tests/services/api.test.ts`
- Alternatively, tests can be co-located next to their source files (e.g. `src/components/Button/Button.test.tsx`). If using co-location, use this `src/tests/` folder strictly for integration tests and global test setup/fixtures.
- Maintain ≥80% test coverage for all service and utility files
- Never test with production credentials; use `.env.test` or mocked services
