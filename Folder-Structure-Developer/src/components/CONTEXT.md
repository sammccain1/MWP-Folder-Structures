# src/components/ — UI Components

You are in the **components directory**. All React and Next.js UI components live here.

## What Belongs Here

- React functional components (`.tsx`)
- Next.js page layouts and shared UI shells
- Reusable UI primitives: buttons, modals, cards, form inputs
- Data visualization components: chart wrappers, map layers, table components
- Component-level CSS modules or styled-component files

## What Does NOT Belong Here

- Business logic or API calls — those go in `src/services/`
- Utility functions — those go in `src/utils/`
- Page-level routing — that goes in `src/app/` (Next.js App Router)

## Naming Convention

```
PascalCase.tsx for all components
PascalCase.test.tsx for component tests

Examples:
  MapView.tsx
  BracketCard.tsx
  ElectionTable.tsx
  MapView.test.tsx
```

## Rules

- Every component must have an explicit `Props` interface — no `any` types
- Use TypeScript strict mode — `noImplicitAny`, `strictNullChecks`
- Components must be pure where possible — side effects belong in `src/services/`
- Never import from `src/services/` inside a component — pass data/callbacks as props
- Keep components focused: one visual responsibility per file
- Co-locate component-specific styles in the same directory (`ComponentName.module.css`)
