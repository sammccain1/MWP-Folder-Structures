---
name: planner
description: Extended planning patterns and ADR templates for the planner agent. Load when planning features involving Supabase schema changes, Next.js App Router architecture, Python ML pipelines, or multi-phase refactors. Provides phasing strategies, risk matrices, and worked examples.
---

# Planner Skill

Extended patterns, templates, and worked examples for the `planner` agent. Stack-specific planning guidance for Sam's projects.

---

## Architecture Decision Record (ADR) Template

Save to `Planning/decisions/YYYY-MM-DD_decision-name.md`:

```markdown
# ADR: [Short Title]

**Date:** 2026-03-25
**Status:** Proposed | Accepted | Deprecated | Superseded
**Supersedes:** [ADR link if applicable]

## Context

[What is the situation? What problem are we solving? What constraints exist?]

## Decision

[What did we decide to do?]

## Consequences

**Positive:**
- [Benefit 1]
- [Benefit 2]

**Negative / Trade-offs:**
- [Trade-off 1]
- [Trade-off 2]

**Neutral:**
- [Side effect that's neither good nor bad]
```

---

## Supabase Schema Change Plan

When planning any DB schema changes:

```markdown
### Phase 1: Migration (non-breaking)
1. Write migration: `supabase/migrations/YYYY-MM-DD_description.sql`
   - Use `ALTER TABLE ... ADD COLUMN` (never drop without separate migration)
   - Add RLS policy for new table/column if user-facing
   - Add index if column appears in WHERE/JOIN

2. Test locally: `supabase db reset && supabase db push`

### Phase 2: Code changes
3. Update TypeScript types (generate via `supabase gen types typescript`)
4. Update Zod/Pydantic schemas to include new field
5. Update any affected API routes and Server Actions

### Phase 3: Verify
6. Run full test suite
7. Manually test affected flows end-to-end
8. Deploy migration to staging first, then production
```

**Never:** Rename or drop a column in the same migration that adds it. Always separate destructive changes into their own migration after the app is deployed and no longer reads the old column.

---

## Next.js App Router Feature Plan Template

```markdown
## Feature: [Name]

### Data Layer
- [ ] New Supabase table/columns? → Schema change plan above
- [ ] New API route: `src/app/api/[route]/route.ts`
  - Auth check: `getServerSession()`
  - Input validation: Zod schema
  - Error handling: `try/catch` → `NextResponse.json({ error }, { status })`

### Server Components
- [ ] `src/app/[route]/page.tsx` — fetch data directly (no `useEffect`)
- [ ] Pass data as props to Client Components

### Client Components
- [ ] `src/components/[Feature]/[FeatureName].tsx` — `"use client"`
- [ ] Use TanStack Query for any client-side refetching
- [ ] Define `interface Props { ... }` before component

### Actions
- [ ] `src/app/[route]/actions.ts` — Server Actions with `"use server"`
- [ ] `revalidatePath()` after mutations

### Tests
- [ ] Unit: `src/tests/[feature].test.ts`
- [ ] E2E: `src/tests/e2e/[feature].spec.ts` — critical path only
```

---

## Python ML Pipeline Plan Template

```markdown
## Pipeline: [Name]

### Data Acquisition
- [ ] Source: [API / CSV / DB query]
- [ ] Script: `ops/scripts/fetch_[name].py`
- [ ] Output: `data/raw/[name]_YYYY-MM-DD.csv`

### Preprocessing
- [ ] Script: `src/[name]/preprocess.py`
- [ ] Input: raw CSV
- [ ] Output: `data/processed/[name]_processed.parquet`
- [ ] Key transforms: [list]

### Feature Engineering
- [ ] Script: `src/[name]/features.py`
- [ ] Features: [list with rationale]
- [ ] Reproducibility: `random_state=42` everywhere

### Model Training
- [ ] Script: `src/[name]/train.py`
- [ ] Algorithm: [e.g., RandomForestClassifier]
- [ ] CV strategy: [e.g., LOSO, 5-fold]
- [ ] Metrics: [e.g., Recall@16, AUC-ROC]
- [ ] Save model: `models/[name]_vN.pkl`

### Evaluation
- [ ] Script: `src/[name]/evaluate.py`
- [ ] Metrics threshold: [define pass/fail line]
- [ ] Notebook: `src/notebooks/[name]-results.ipynb`

### Tests
- [ ] `src/tests/test_preprocess.py` — input/output shape assertions
- [ ] `src/tests/test_features.py` — feature value range checks
- [ ] `src/tests/test_train.py` — smoke test on tiny dataset
```

---

## Phasing Strategy for Large Features

```
Phase 1 — Skeleton (mergeable alone)
  → DB schema migration + empty API routes + stub UI
  → Nothing works end-to-end yet but nothing breaks

Phase 2 — Happy Path (mergeable alone)
  → Core logic implemented
  → Success case works end-to-end
  → Unit tests for core logic

Phase 3 — Error Handling (mergeable alone)
  → All edge cases handled
  → Loading / empty / error states in UI
  → E2E tests for critical journeys

Phase 4 — Polish (mergeable alone)
  → Performance optimizations
  → Monitoring / logging
  → Documentation updated
```

Each phase is an independent PR. Never make Phase 4 a prerequisite for Phase 1 to work.

---

## Risk Matrix

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Supabase RLS blocks a query | Medium | High | Test RLS policies locally before deploy |
| Schema migration breaks prod | Low | Critical | Always migration → deploy → validate before cleanup |
| Flaky E2E test blocks CI | Medium | Medium | Quarantine with `test.fixme` and track in issues |
| ML model underperforms | Medium | High | Define metric threshold before training; document in ADR |
| Auth middleware misconfiguration | Low | Critical | Test both logged-in and logged-out states before merge |
