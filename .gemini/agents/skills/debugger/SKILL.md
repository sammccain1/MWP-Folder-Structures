---
name: debugger
description: Systematic debugging skill for Python, TypeScript/Next.js, SQL, and data pipelines. Load when diagnosing errors, tracing unexpected behavior, or debugging CI failures. Provides stack-specific debug commands, common root causes, and a structured isolation workflow.
---

# Debugger Skill

Systematic debugging patterns for Sam's stack. Use alongside the `debugger` agent for structured root-cause analysis.

---

## Debugging Workflow

```
1. Reproduce reliably → 2. Isolate the scope → 3. Form a hypothesis
→ 4. Test the hypothesis → 5. Fix → 6. Verify fix didn't break anything
```

Never skip step 1. If you can't reproduce it, you can't fix it.

---

## Python / FastAPI Debugging

### Quick Commands

```bash
# Run with verbose error tracing
python -m pytest tests/ -v --tb=long

# Drop into debugger on failure
python -m pytest tests/ --pdb

# Profile a slow script
python -m cProfile -o profile.out script.py
python -m pstats profile.out

# Check for import errors
python -c "import yourmodule"

# FastAPI: run with auto-reload and see full tracebacks
uvicorn app.main:app --reload --log-level debug
```

### Common Python Root Causes

| Symptom | Likely Cause |
|---|---|
| `None` where object expected | Missing null check, function that sometimes returns nothing |
| Stale data in tests | Fixtures sharing state across tests — missing teardown |
| `KeyError` in dict access | Use `.get()` or check key existence first |
| Pandas shape mismatch | DataFrame was filtered before expected, check upstream |
| `RecursionError` | Circular import or recursive function without base case |
| Different behavior in prod vs. local | Env var not set in prod — check `.env` vs Vercel dashboard |

### Tracing a FastAPI Request

```python
# Add to any route for detailed tracing
import logging
logger = logging.getLogger(__name__)

@app.get("/api/data")
async def get_data(request: Request):
    logger.debug("Request headers: %s", dict(request.headers))
    logger.debug("Query params: %s", dict(request.query_params))
    # ... rest of handler
```

---

## TypeScript / Next.js Debugging

### Quick Commands

```bash
# Type-check without building
npx tsc --noEmit

# Find the exact error in Next.js build
next build 2>&1 | head -100

# Run single test file with verbose output
npx jest src/path/to/file.test.ts --verbose

# Check bundle size (find what's bloating it)
ANALYZE=true next build

# Debug a server action by adding console.error and checking terminal (not browser)
```

### Common Next.js Root Causes

| Symptom | Likely Cause |
|---|---|
| `useState` / `useEffect` errors in Server Component | Client-only hook in RSC — add `"use client"` |
| Hydration mismatch | Server and client render different HTML — check date/random/user-agent code |
| Stale data after mutation | Forgot `revalidatePath()` or `revalidateTag()` after Server Action |
| `window is not defined` | Accessing browser API during SSR — wrap in `useEffect` or check `typeof window` |
| Auth redirect not working in middleware | Matcher pattern incorrect in `middleware.ts` |
| Infinite re-render loop | `useEffect` deps include an object/array created inline (new reference each render) |

### Debugging a Server Action

```typescript
export async function myAction(formData: FormData) {
  'use server'
  
  // Log to terminal (server-side), not browser console
  console.log('Action called with:', Object.fromEntries(formData))
  
  try {
    // ... logic
  } catch (error) {
    console.error('Action failed:', error) // Visible in terminal
    throw error // Re-throw so client sees the error
  }
}
```

---

## SQL / Supabase Debugging

```sql
-- Check which RLS policies are active on a table
SELECT * FROM pg_policies WHERE tablename = 'your_table';

-- Explain a slow query
EXPLAIN ANALYZE SELECT * FROM posts WHERE user_id = $1;

-- Check missing indexes
SELECT schemaname, tablename, attname, n_distinct, correlation
FROM pg_stats
WHERE tablename = 'your_table';

-- Test RLS as a specific user (Supabase SQL editor)
SET LOCAL role = authenticated;
SET LOCAL request.jwt.claims = '{"sub": "user-uuid-here"}';
SELECT * FROM your_table;
```

---

## Data Pipeline Debugging

```python
# Checkpoint pattern — save intermediate state to inspect
df.to_csv("/tmp/checkpoint_after_step1.csv", index=False)
print(f"Shape after step 1: {df.shape}")
print(df.dtypes)
print(df.head())
print(df.isna().sum())  # Check for unexpected nulls

# Narrow down transformation bugs
def debug_transform(df: pd.DataFrame, step_name: str) -> pd.DataFrame:
    print(f"\n=== {step_name} ===")
    print(f"Shape: {df.shape}")
    print(f"Nulls:\n{df.isna().sum()}")
    return df

# Chain it
result = (df
    .pipe(debug_transform, "raw")
    .pipe(clean_data)
    .pipe(debug_transform, "after clean")
    .pipe(transform_data)
    .pipe(debug_transform, "final")
)
```

---

## CI Failure Debugging

```bash
# Run exactly what CI runs, locally
act -j test  # Using 'act' to run GitHub Actions locally

# Reproduce a Docker CI environment
docker build -t app-test -f ops/deploy/Dockerfile .
docker run --env-file .env app-test pytest

# Check if env vars are the issue
env | grep -i api  # See what's set
```

**Most common CI-only failures:**
1. Env var not set in CI secrets — compare `.env.example` against CI vars
2. Port conflict — other service already using the port
3. Race condition — test assertions run before async operation completes
4. Different OS file path separator (Windows CI)
5. Dependency not installed — check `requirements.txt` / `package.json` is committed
