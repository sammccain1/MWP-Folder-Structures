# SQL Rules

Stack: PostgreSQL (Supabase), SQLAlchemy, Pandas, raw SQL migrations

## Safety — Non-Negotiable

- **ALWAYS use parameterized queries** — never concatenate user input into a SQL string. This is the #1 SQL injection vector.
- **NEVER run `DROP TABLE` or `DELETE` without a `WHERE` clause** in code — always guard destructive statements with an explicit condition check.
- **NEVER modify production directly** — all schema changes go through a migration file first.

```python
# ✅ Parameterized
cursor.execute("SELECT * FROM users WHERE id = %s AND org_id = %s", (user_id, org_id))

# ❌ String concat — SQL injection waiting to happen
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")
```

## Schema Design

- All table and column names use `snake_case` — no camelCase, no PascalCase.
- Every table must have: `id UUID PRIMARY KEY DEFAULT gen_random_uuid()`, `created_at TIMESTAMPTZ DEFAULT NOW()`, `updated_at TIMESTAMPTZ DEFAULT NOW()`.
- Boolean columns: prefix with `is_` or `has_` — e.g., `is_active`, `has_verified_email`.
- Foreign key columns: `{referenced_table_singular}_id` — e.g., `user_id`, `project_id`.
- Avoid `NULL` as a default for required fields — use `NOT NULL` with an explicit default where possible.

```sql
CREATE TABLE projects (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT        NOT NULL,
  owner_id   UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  is_active  BOOLEAN     NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

## Migrations

- **Forward-only migration strategy** — write discrete `up` migration files. Never modify an existing migration that has been applied anywhere.
- Name migration files: `YYYY-MM-DD_NNN_description.sql` — e.g., `2026-03-31_001_add_projects_table.sql`.
- Every migration must be idempotent where possible — use `CREATE TABLE IF NOT EXISTS`, `ADD COLUMN IF NOT EXISTS`.
- Test migrations on a local db snapshot before applying to staging or production.

```sql
-- 2026-03-31_001_add_projects_table.sql
-- UP
CREATE TABLE IF NOT EXISTS projects (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT        NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS projects_created_at_idx ON projects (created_at DESC);
```

## Queries

- **Explicit column selection** — never `SELECT *` in application code. Always name the columns you need.
- **Limit result sets** — always use `LIMIT` for paginated queries; never unbounded `SELECT` on large tables.
- **Use CTEs for readability** on complex queries — a well-named `WITH` clause is better than nested subqueries.
- **Indexes** — add an index for every column used in a `WHERE`, `JOIN ON`, or `ORDER BY` clause on tables expected to grow beyond ~10k rows.

```sql
-- ✅ Explicit columns, limited, CTE for clarity
WITH active_users AS (
  SELECT id, email, created_at
  FROM users
  WHERE is_active = true
    AND created_at > NOW() - INTERVAL '30 days'
)
SELECT u.id, u.email, p.name AS project_name
FROM active_users u
JOIN projects p ON p.owner_id = u.id
ORDER BY u.created_at DESC
LIMIT 100 OFFSET $1;

-- ❌
SELECT * FROM users JOIN projects ON projects.owner_id = users.id;
```

## Supabase / Row-Level Security

- **RLS must be enabled** on every table that stores user or client data — `ALTER TABLE projects ENABLE ROW LEVEL SECURITY`.
- Write a `SELECT` policy and an `INSERT/UPDATE/DELETE` policy separately — never combine into one overly broad policy.
- Always test policies with `SET ROLE authenticated; SELECT ...` to confirm they behave correctly before deploying.

```sql
-- SELECT: users can only see their own projects
CREATE POLICY "users_select_own_projects"
ON projects FOR SELECT
USING (auth.uid() = owner_id);

-- INSERT: users can only create projects for themselves
CREATE POLICY "users_insert_own_projects"
ON projects FOR INSERT
WITH CHECK (auth.uid() = owner_id);
```

## Pandas + SQL Interop

- Use `pd.read_sql_query(sql, conn, params=(...))` — never `pd.read_sql_query(f"... {var}")`.
- When writing DataFrames back to the database, use `df.to_sql(..., if_exists='append', index=False)` — never `if_exists='replace'` in production (it drops and recreates the table).
- Cast DataFrame columns to the correct types before writing: integers should be `Int64` (nullable), not `float64` with NaN representing missing integers.
