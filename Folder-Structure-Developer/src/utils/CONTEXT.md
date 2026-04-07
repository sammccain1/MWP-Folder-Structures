# src/utils/ — Pure Functions & Helpers

You are in the **utils directory**. All shared helper functions, formatters, and constants live here.

## What Belongs Here

- **Pure Functions** — functions that always return the same output for the same input with no side effects
- **Formatters** — date formatters, currency formatters, string manipulators
- **Math/Logic Helpers** — custom algorithms, statistics helpers
- **Constants** — shared static values (e.g., `constants.ts` or `enums.py`)
- **Type Definitions** — shared TypeScript interfaces and types

## What Does NOT Belong Here

- **Side Effects** — anything that makes an API call, writes to disk, or reads from a DB belongs in `src/services/`
- **UI Components** — React/Next.js components belong in `src/components/`
- **State Management** — Redux slices or React contexts belong closer to the components

## Rules

- Utils must be highly testable (pure functions are the easiest to test)
- Avoid importing from `src/services/` or `src/components/` into `src/utils/` to prevent circular dependencies
- If a utility is only used by one specific component, leave it in that component's file. Only move it to `src/utils/` if it's shared across the app.
