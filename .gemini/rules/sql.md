# SQL Rules

Guardrails for PostgreSQL (Supabase), SQLAlchemy, and raw SQL migrations.

---

## Safety — Non-Negotiable

```sql
-- ✅ ALWAYS use parameterized queries
-- Python (psycopg2/asyncpg)
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))

-- TypeScript (Supabase)
const { data } = await supabase.from('users').select().eq('id', user_id)

-- ❌ NEVER interpolate strings — SQL Injection risk #1
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")
```

**Rule:** Every single query that touches user input must be parameterized. No exceptions.

---

## Schema Design

### Naming Conventions
- **Snake Case:** All table and column names (`user_profiles`, not `UserProfiles`).
- **Plural Tables:** `users`, `posts`, `election_results`.
- **Primary Keys:** Always `id UUID PRIMARY KEY DEFAULT gen_random_uuid()`.
- **Timestamps:** Always include `created_at` and `updated_at` with `TIMESTAMPTZ`.

### Boolean Columns
- Prefix with `is_`, `has_`, or `can_`.
- Example: `is_active`, `has_voted`, `can_edit`.

```sql
CREATE TABLE IF NOT EXISTS election_results (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  fips        TEXT        NOT NULL,
  year        INTEGER     NOT NULL,
  dem_votes   INTEGER     NOT NULL DEFAULT 0,
  rep_votes   INTEGER     NOT NULL DEFAULT 0,
  is_verified BOOLEAN     NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (fips, year)
);
```

---

## Query Optimization

### Indices
- Index columns used in `WHERE`, `JOIN` conditions, and `ORDER BY`.
- **Partial Indices:** Use for common filters to save space.
- **Composite Indices:** Order matters (most selective column first).

```sql
-- Index for common filtered query
CREATE INDEX idx_verified_results ON election_results(year) WHERE is_verified = true;

-- Composite index
CREATE INDEX idx_fips_year ON election_results(fips, year);
```

### Explaining Queries
- Always run `EXPLAIN ANALYZE` on slow queries to identify seq scans.
- Aim for **Index Scan** or **Index Only Scan** on large tables.

---

## Advanced Patterns

### CTEs (Common Table Expressions)
- Use for readability in complex joins.

```sql
WITH state_totals AS (
  SELECT state, SUM(total_votes) as state_sum
  FROM results
  GROUP BY state
)
SELECT r.county, r.total_votes / st.state_sum as weight
FROM results r
JOIN state_totals st ON r.state = st.state;
```

### Window Functions
- Use for rankings or running totals without self-joins.

```sql
SELECT 
  county, 
  year, 
  total_votes,
  RANK() OVER (PARTITION BY year ORDER BY total_votes DESC) as vote_rank
FROM results;
```

---

## Row Level Security (RLS)

- Enable RLS on all tables in the `public` schema in Supabase.
- Policies should be as restrictive as possible.

```sql
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
ON profiles FOR SELECT
USING (auth.uid() = user_id);
```

---

## Rules Summary

| Rule | Rationale |
|---|---|
| No String Interpolation | Absolute protection against SQL Injection |
| Consistent Naming | Machine and human readability across the stack |
| Implicit PK/Timestamps | Consistency and auditability by default |
| EXPLAIN ANALYZE | Proactive performance management |
| RLS Mandatory | Defense-in-depth for multi-tenant data |
