---
name: db-migrate
description: Guided database migration workflow. Creates a timestamped migration file, applies it locally, diffs the schema, and generates a rollback. Enforces the YYYY-MM-DD_NNN_description.sql naming convention from the SQL rules.
allowed_tools: ["Read", "Write", "Bash"]
---

# /db-migrate

Safe, traceable database migration workflow. Never modify schema without going through this.

## Step 1 — Describe the Change

Before touching any files, answer:

1. What table(s) are affected?
2. Is this additive (adding columns/tables) or destructive (dropping, renaming)?
3. What is the rollback? Can it be done without data loss?

> ⚠️ **Destructive changes** (DROP, RENAME column, ALTER type) require a data migration plan. Additive changes are safe to deploy to production without a maintenance window.

## Step 2 — Find the Next Migration Number

```bash
# List existing migrations
ls -1 migrations/ 2>/dev/null | sort | tail -5

# Determine next sequence number
LAST=$(ls migrations/*.sql 2>/dev/null | sort | tail -1 | grep -oE '_[0-9]{3}_' | tr -d '_')
NEXT=$(printf "%03d" $((10#${LAST:-0} + 1)))
echo "Next migration number: $NEXT"
```

## Step 3 — Create the Migration File

Name format: `YYYY-MM-DD_NNN_description.sql`

```bash
DATE=$(date +%Y-%m-%d)
# Example: 2026-03-31_002_add_projects_table.sql
MIGRATION_FILE="migrations/${DATE}_${NEXT}_[description].sql"
touch "$MIGRATION_FILE"
```

Write the migration using idempotent patterns:

```sql
-- migrations/YYYY-MM-DD_NNN_description.sql
-- Description: [What this migration does and why]
-- Rollback: [migrations/YYYY-MM-DD_NNN_rollback_description.sql]

-- ── UP ───────────────────────────────────────────────────────────
BEGIN;

-- Use IF NOT EXISTS for additive changes
CREATE TABLE IF NOT EXISTS [table_name] (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  [column]   [type]      NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS [table]_[column]_idx ON [table_name] ([column]);

COMMIT;
```

## Step 4 — Create the Rollback File

```sql
-- migrations/YYYY-MM-DD_NNN_rollback_description.sql
-- Rolls back: YYYY-MM-DD_NNN_description.sql

BEGIN;
DROP TABLE IF EXISTS [table_name];
COMMIT;
```

## Step 5 — Apply Locally and Verify

```bash
# Supabase local
supabase db reset 2>/dev/null || true
supabase migration up

# Or raw psql
psql "$DATABASE_URL" -f "migrations/${MIGRATION_FILE}"

# Verify schema
psql "$DATABASE_URL" -c "\d [table_name]"
```

## Step 6 — Check RLS (Supabase)

If the table stores user data, immediately add RLS policies:

```sql
-- Enable RLS
ALTER TABLE [table_name] ENABLE ROW LEVEL SECURITY;

-- SELECT: users can only see their own rows
CREATE POLICY "[table]_select_own"
ON [table_name] FOR SELECT
USING (auth.uid() = user_id);

-- INSERT: users can only insert for themselves
CREATE POLICY "[table]_insert_own"
ON [table_name] FOR INSERT
WITH CHECK (auth.uid() = user_id);
```

## Step 7 — Commit

```bash
git add migrations/
git commit -m "feat(db): add migration $(basename $MIGRATION_FILE .sql)"
```

## Checklist

- [ ] Migration file named `YYYY-MM-DD_NNN_description.sql`
- [ ] All statements use `IF NOT EXISTS` where applicable
- [ ] Rollback file created alongside migration
- [ ] Tested on local database — schema matches expectation
- [ ] RLS enabled if table stores user/client data
- [ ] No `DROP` without data export plan
- [ ] Migration committed before applying to staging
