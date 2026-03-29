---
name: refactorer
description: Extended refactoring patterns for Python, TypeScript/Next.js, and data pipeline code. Load when consolidating duplicates, modernizing legacy patterns, or cleaning up after a rapid prototype. Provides stack-specific refactor recipes, safe removal checklists, and common before/after examples.
---

# Refactorer Skill

Extended patterns and recipes for the `refactorer` agent. Stack-specific before/after examples and safe removal workflows.

---

## Python Refactor Recipes

### 1. Eliminate In-Place Pandas Mutations

```python
# ❌ Before — mutates DataFrame in place
def clean_data(df):
    df["name"] = df["name"].str.strip()
    df["email"] = df["email"].str.lower()
    df.dropna(subset=["email"], inplace=True)
    return df

# ✅ After — immutable, chainable
def clean_data(df: pd.DataFrame) -> pd.DataFrame:
    return (
        df
        .assign(
            name=df["name"].str.strip(),
            email=df["email"].str.lower()
        )
        .dropna(subset=["email"])
        .reset_index(drop=True)
    )
```

### 2. Replace Raw SQL Strings with Parameterized Queries

```python
# ❌ Before
def get_user(user_id):
    return db.execute(f"SELECT * FROM users WHERE id = {user_id}")

# ✅ After
def get_user(user_id: str) -> dict | None:
    result = db.execute(
        "SELECT id, name, email FROM users WHERE id = %s",
        (user_id,)
    )
    return result.fetchone()
```

### 3. Extract Magic Numbers to Constants

```python
# ❌ Before
if score > 0.73:
    rank = "Elite"
elif score > 0.58:
    rank = "Strong"

# ✅ After
ELITE_THRESHOLD = 0.73
STRONG_THRESHOLD = 0.58

def classify_score(score: float) -> str:
    if score > ELITE_THRESHOLD:
        return "Elite"
    if score > STRONG_THRESHOLD:
        return "Strong"
    return "Standard"
```

### 4. Replace Procedural Script with Functions

```python
# ❌ Before — 200-line script with no functions
data = pd.read_csv("data.csv")
# ... 50 lines of transforms ...
model = RandomForestClassifier()
# ... 50 lines of training ...
results = []
for team in teams:
    # ... 50 lines of evaluation ...

# ✅ After — composable pipeline
def load_data(path: str) -> pd.DataFrame: ...
def preprocess(df: pd.DataFrame) -> pd.DataFrame: ...
def train_model(df: pd.DataFrame) -> RandomForestClassifier: ...
def evaluate(model, teams: list) -> list[Result]: ...

def main():
    df = load_data("data.csv")
    clean_df = preprocess(df)
    model = train_model(clean_df)
    results = evaluate(model, extract_teams(clean_df))
    save_results(results)
```

---

## TypeScript / React Refactor Recipes

### 1. Extract Inline Logic to Named Functions

```typescript
// ❌ Before — inline logic obscures intent
const validUsers = users.filter(u =>
  u.active && u.email && !u.email.includes("test") && u.createdAt > cutoff
);

// ✅ After — named predicate, testable independently
const isEligibleUser = (user: User, cutoff: Date): boolean =>
  user.active &&
  !!user.email &&
  !user.email.includes("test") &&
  user.createdAt > cutoff;

const validUsers = users.filter(u => isEligibleUser(u, cutoff));
```

### 2. Replace Prop Drilling with Composition

```typescript
// ❌ Before — user passed through 3 layers
<Layout user={user}>
  <Dashboard user={user}>
    <ProfileCard user={user} />

// ✅ After — pass only what the leaf needs, or use context
// Option A: Composition
<Layout>
  <Dashboard>
    <ProfileCard name={user.name} avatarUrl={user.avatarUrl} />

// Option B: Auth context at the top level
const { user } = useAuth(); // In ProfileCard directly
```

### 3. Modernize Data Fetching (Pages Router → App Router)

```typescript
// ❌ Before — getServerSideProps (Pages Router)
export async function getServerSideProps({ params }) {
  const data = await fetchData(params.id);
  return { props: { data } };
}

// ✅ After — async Server Component (App Router)
export default async function Page({ params }: { params: { id: string } }) {
  const data = await fetchData(params.id);
  return <DataView data={data} />;
}
```

### 4. Consolidate Duplicate Fetch Logic

```typescript
// ❌ Before — same fetch in 3 components
// BracketView.tsx: const res = await fetch('/api/bracket')
// StatsPanel.tsx: const res = await fetch('/api/bracket')
// ExportButton.tsx: const res = await fetch('/api/bracket')

// ✅ After — single service function
// src/services/bracketService.ts
export async function fetchBracket(): Promise<BracketData> {
  const res = await fetch('/api/bracket', { next: { revalidate: 60 } });
  if (!res.ok) throw new ApiError('Failed to fetch bracket', res.status);
  return res.json();
}
```

---

## Safe Removal Checklist

Before deleting any file or export:

```bash
# 1. Confirm nothing imports it
grep -r "import.*YourComponent" src/ --include="*.ts" --include="*.tsx"
grep -r "from.*your-module" src/ --include="*.py"

# 2. Check for dynamic imports (string-based)
grep -r "\"YourComponent\"" src/
grep -r "'your-module'" src/

# 3. Check git history for context
git log --all --full-history -- path/to/file

# 4. Run tests after removal
npm test  # or pytest
```

**When in doubt, don't remove.** Mark as `@deprecated` and give it one sprint before deleting.

---

## Knip / Dead Code Triage

```bash
npx knip --reporter compact

# Typical output categories:
# - Unused files → safe to delete after grep check
# - Unused exports → remove export keyword (keep the function if used internally)
# - Unused dependencies → remove from package.json
# - Unlisted dependencies → add to package.json explicitly
```

Priority order for cleanup: **dependencies → unused exports → unused files → duplicate logic**
