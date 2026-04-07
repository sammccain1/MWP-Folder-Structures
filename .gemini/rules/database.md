# Database Rules

Stack: PostgreSQL + Supabase + SQLAlchemy (async) + Prisma / Supabase client (TypeScript)

---

## Query Safety — Non-Negotiable

```python
# ✅ Always parameterized — never string interpolation
cursor.execute("SELECT * FROM users WHERE id = %s AND org_id = %s", (user_id, org_id))

# ✅ SQLAlchemy ORM — parameterized by default
result = await db.execute(select(User).where(User.id == user_id))

# ✅ Pandas read_sql — parameterized
df = pd.read_sql_query(
    "SELECT * FROM results WHERE state = %s AND year = %s",
    conn,
    params=("CA", 2024),
)

# ❌ Never — SQL injection
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")
pd.read_sql_query(f"SELECT * FROM results WHERE state = '{state}'", conn)
```

---

## Async SQLAlchemy (FastAPI)

```python
# db.py — async session factory
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.pool import NullPool

engine = create_async_engine(
    settings.DATABASE_URL,
    pool_size=10,           # max connections in pool
    max_overflow=20,        # burst connections above pool_size
    pool_pre_ping=True,     # check connection health before use
    echo=False,             # never True in production — logs all SQL
)

AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)

# Dependency — yields session, ensures cleanup
async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
```

---

## Connection Pooling Rules

| Setting | Value | Rationale |
|---|---|---|
| `pool_size` | 10 | Base connections kept alive |
| `max_overflow` | 20 | Burst headroom during traffic spikes |
| `pool_pre_ping` | `True` | Detects and replaces stale connections |
| `pool_recycle` | 3600 | Recycle connections after 1 hour (avoid timeout drops) |
| `echo` | `False` in production | Logging every query floods logs and leaks data |

```python
# ❌ NullPool in production — creates/destroys connection per query (very slow)
engine = create_async_engine(url, poolclass=NullPool)
# ✅ NullPool is acceptable in Alembic migration scripts only
```

---

## Migrations

```sql
-- Naming: YYYY-MM-DD_NNN_description.sql
-- 2026-04-07_001_add_county_results_table.sql

-- ✅ Always idempotent
CREATE TABLE IF NOT EXISTS county_results (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  fips        TEXT        NOT NULL,
  year        INTEGER     NOT NULL,
  dem_votes   INTEGER     NOT NULL DEFAULT 0,
  rep_votes   INTEGER     NOT NULL DEFAULT 0,
  total_votes INTEGER     NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (fips, year)
);

-- ✅ Index on query-heavy columns
CREATE INDEX IF NOT EXISTS idx_county_results_year ON county_results(year);
CREATE INDEX IF NOT EXISTS idx_county_results_fips ON county_results(fips);
```

**Rules:**
- One migration = one logical change — never combined drop+add in a single file
- Never modify an applied migration — always write a new one
- Test: local reset → staging push → production push (never skip staging)
- Write `DOWN` SQL in a comment at the bottom of every migration file

---

## Indexes

```sql
-- ✅ Index columns used in WHERE, JOIN ON, or ORDER BY on large tables
CREATE INDEX idx_results_state_year ON election_results(state, year);

-- ✅ Partial index for common filtered query (more selective = faster)
CREATE INDEX idx_active_users ON users(created_at) WHERE is_active = true;

-- ❌ Don't index low-cardinality columns — more overhead than benefit
CREATE INDEX idx_users_is_active ON users(is_active);  -- only 2 values: bad

-- ✅ Composite index — most selective column first
CREATE INDEX idx_results_state_year ON results(state, year);
-- This helps: WHERE state = 'CA' AND year = 2024
-- This does NOT help: WHERE year = 2024  (year is not the leading column)
```

---

## Supabase — Row Level Security

```sql
-- Enable on every user-data table — no exceptions
ALTER TABLE county_results ENABLE ROW LEVEL SECURITY;

-- Separate policies per operation — never one catch-all policy
CREATE POLICY "users_select_own_results"
  ON county_results FOR SELECT
  USING (auth.uid() = submitted_by);

CREATE POLICY "users_insert_own_results"
  ON county_results FOR INSERT
  WITH CHECK (auth.uid() = submitted_by);

-- Test policies before deploying
SET ROLE authenticated;
SELECT * FROM county_results;  -- should only see your own rows
RESET ROLE;
```

```bash
# Always regenerate types after schema changes
supabase gen types typescript --local > src/types/supabase.ts
```

---

## Pandas / Data Write-Back

```python
# ✅ Append — safe for production pipelines
df.to_sql("results", con=engine, if_exists="append", index=False)

# ❌ Replace — drops and recreates the entire table including indexes and RLS
df.to_sql("results", con=engine, if_exists="replace", index=False)

# ✅ Cast nullable integers before writing (avoids float64 with NaN issue)
df["dem_votes"] = df["dem_votes"].astype("Int64")  # nullable integer
df["fips"] = df["fips"].str.zfill(5)               # FIPS must be 5-char string

# ✅ Upsert pattern via raw SQL + ON CONFLICT
upsert_sql = """
  INSERT INTO county_results (fips, year, dem_votes, rep_votes, total_votes)
  VALUES (%s, %s, %s, %s, %s)
  ON CONFLICT (fips, year) DO UPDATE SET
    dem_votes = EXCLUDED.dem_votes,
    rep_votes = EXCLUDED.rep_votes,
    total_votes = EXCLUDED.total_votes,
    updated_at = NOW();
"""
with engine.connect() as conn:
    conn.execute(text(upsert_sql), rows)
```

---

## Rules Summary

| Rule | Rationale |
|---|---|
| Always parameterized queries | SQL injection prevention — #1 database attack vector |
| Async sessions with rollback on error | Prevents connection leaks and partial writes |
| `pool_pre_ping=True` | Detects stale connections before queries fail |
| Never `echo=True` in production | Logs every SQL statement — performance hit and data exposure |
| One migration per logical change | Safe rollback; atomic diffs in git |
| Index `WHERE`, `JOIN`, `ORDER BY` columns | Prevents full table scans on large datasets |
| RLS on every user-data table | Defense in depth — protects even if app-level auth fails |
| `if_exists='append'` not `'replace'` | Prevents catastrophic table drops in prod pipelines |