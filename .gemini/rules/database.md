# Database Rules

Stack: PostgreSQL + Supabase + SQLAlchemy (Python) + Prisma / raw SQL (TypeScript)

## Query Safety

- **Always parameterized** — no string interpolation in SQL, ever
- Python: `cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))`
- TypeScript: `prisma.user.findUnique({ where: { id } })` or tagged template literals with Supabase
- Never use `eval()`, `.format()`, or f-strings to build SQL

## Migrations

- One migration = one logical change (add column, add index, rename — never combined)
- Never drop a column in the same migration that adds its replacement
- Naming: `YYYY-MM-DD_description.sql` — matches the file naming convention
- All migrations must be reversible — write the `DOWN` migration before committing the `UP`
- Test order: local reset → staging push → production push (never skip staging)

```sql
-- ✅ Safe: additive migration
ALTER TABLE users ADD COLUMN display_name TEXT;
CREATE INDEX idx_users_display_name ON users(display_name);

-- ❌ Dangerous: combined drop+add in one migration
ALTER TABLE users DROP COLUMN name;
ALTER TABLE users ADD COLUMN display_name TEXT;
```

## Supabase Specifics

- Every user-facing table needs RLS enabled: `ALTER TABLE [table] ENABLE ROW LEVEL SECURITY;`
- Generate TypeScript types after every schema change: `supabase gen types typescript --local > src/types/supabase.ts`
- Storage bucket policies follow the same RLS principles as table policies
- Never call the service role key from the client — only from server-side code

## Indexes

- Add index if column appears in `WHERE`, `JOIN ON`, or `ORDER BY` in production queries
- Composite indexes: column order matters — put the most selective column first
- Don't index columns with very low cardinality (booleans, enums with 2-3 values)

## Pandas / Data Layer

- Never mutate a DataFrame in place — always assign to a new variable
- Use `.copy()` when slicing to avoid `SettingWithCopyWarning`
- `read_sql()` with parameterized query only — never string-concat the SQL argument
- Prefer `parquet` over CSV for intermediate pipeline outputs (typed, compressed, faster)