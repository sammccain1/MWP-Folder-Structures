---
name: code-review
description: Detailed reference patterns for the code-reviewer agent. Load when conducting reviews on Python/FastAPI, TypeScript/Next.js, React, SQL, or data pipeline code. Provides stack-specific anti-patterns, immutability rules, and AI-generated code review addenda.
---

# Code Review Skill

Extended reference for the `code-reviewer` agent. Stack-specific patterns, anti-pattern catalogs, and review templates for Sam's primary stack.

---

## Python / FastAPI Patterns

### Anti-Patterns to Flag

```python
# ❌ Mutable default argument — a classic Python gotcha
def add_item(item, cart=[]):
    cart.append(item)  # Shared across all calls!
    return cart

# ✅ Use None sentinel
def add_item(item, cart=None):
    cart = cart or []
    return [*cart, item]  # Immutable — return new list

# ❌ Broad exception catch — swallows real errors
try:
    result = risky_operation()
except:
    pass

# ✅ Catch specific exceptions, always log
try:
    result = risky_operation()
except ValueError as e:
    logger.error("Validation failed: %s", e)
    raise HTTPException(status_code=400, detail=str(e))

# ❌ DataFrame mutation in place
df["new_col"] = df["old_col"].apply(transform)

# ✅ Assign to new variable
df = df.assign(new_col=df["old_col"].apply(transform))

# ❌ Printing to stdout in production code
print(f"Processing {user_id}")

# ✅ Structured logging
import logging
logger = logging.getLogger(__name__)
logger.info("Processing user", extra={"user_id": user_id})
```

### FastAPI-Specific
- Every route that accepts a body must use a **Pydantic model** — no raw `request.json()`
- `response_model=` must be set on all endpoints to prevent data leakage
- Background tasks must not share mutable state with the request context
- Dependency injection (`Depends`) is the only approved way to inject auth, DB sessions, and config

---

## TypeScript / React Patterns

### Anti-Patterns to Flag

```typescript
// ❌ any type — defeats TypeScript's purpose
function process(data: any) { ... }

// ✅ Explicit typing
function process(data: UserRecord) { ... }

// ❌ Optional chaining abuse — masks real nullability issues
const name = user?.profile?.address?.city?.name ?? "Unknown"
// If this chain is expected to always resolve, something is wrong upstream

// ❌ useEffect with missing deps
useEffect(() => {
  fetchUser(userId);
}, []); // userId missing

// ✅ Complete deps — or use a data-fetching library (TanStack Query)
useEffect(() => {
  fetchUser(userId);
}, [userId]);

// ❌ Index as key with mutable lists
{items.map((item, i) => <Card key={i} />)}

// ✅ Stable ID as key
{items.map(item => <Card key={item.id} />)}

// ❌ Prop drilling 3+ levels deep
<App user={user}>
  <Dashboard user={user}>
    <Profile user={user} />

// ✅ Context, composition, or state management
```

### React Performance Red Flags
- Component renders on every parent render → `React.memo()` or restructure
- Expensive calculation in render body → `useMemo()`
- Callback re-created every render and passed to memoized child → `useCallback()`
- Large list without virtualization → suggest `react-window` or `react-virtual`

---

## Data Pipeline / ML Patterns

### Anti-Patterns to Flag

```python
# ❌ Reading entire dataset into memory
df = pd.read_csv("massive_file.csv")

# ✅ Chunk reading for large files
for chunk in pd.read_csv("massive_file.csv", chunksize=10_000):
    process(chunk)

# ❌ Hardcoded file paths
DATA_PATH = "/Users/sam/data/raw/file.csv"

# ✅ Config-driven paths via env or a config module
DATA_PATH = os.getenv("DATA_PATH", "data/raw/file.csv")

# ❌ Non-reproducible randomness
model = RandomForestClassifier()
X_train, X_test = train_test_split(X, y)

# ✅ Set random seed everywhere
model = RandomForestClassifier(random_state=42)
X_train, X_test = train_test_split(X, y, random_state=42)
```

---

## SQL / Database Patterns

```sql
-- ❌ SELECT * on user-facing queries — over-fetches, leaks schema
SELECT * FROM users WHERE id = $1;

-- ✅ Explicit columns
SELECT id, name, email FROM users WHERE id = $1;

-- ❌ Missing index on FK or WHERE column
SELECT * FROM posts WHERE user_id = $1;  -- needs index on user_id

-- ❌ N+1 inside a loop
-- ✅ Use JOIN or batch fetch (see code-reviewer.md for examples)
```

---

## Review Severity Quick Reference

| Pattern | Severity |
|---|---|
| Hardcoded secret/key | CRITICAL |
| SQL injection / no parameterization | CRITICAL |
| Missing auth on write route | CRITICAL |
| DataFrame mutation in place | HIGH |
| Missing Pydantic validation | HIGH |
| `any` type in TypeScript | HIGH |
| `useEffect` missing deps | HIGH |
| Missing error handling | HIGH |
| Index as key in lists | MEDIUM |
| `console.log` left in | MEDIUM |
| Magic numbers | LOW |
| Missing JSDoc on exports | LOW |

---

## AI-Generated Code Addenda

When reviewing AI-generated diffs specifically:
1. Check for **hallucinated imports** — imports that don't exist in the project
2. Check for **stale context** — AI used outdated patterns (e.g., Pages Router patterns in an App Router project)
3. Check for **hidden coupling** — AI added a global side-effect or mutated shared state to make a test pass
4. Check that the AI didn't **silently change behavior** to make a function simpler — diff the before/after semantics
5. Flag any **model escalation** — did the AI suggest using a slower/pricier model without clear justification?
