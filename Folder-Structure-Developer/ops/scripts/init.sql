-- init.sql — Database initialization script
-- MWP Developer Template
-- Runs once when the PostgreSQL container first starts (via docker-compose volume mount)
--
-- Usage:
--   Automatically executed by docker-compose.yml on first `docker-compose up`
--   To re-run: docker-compose down -v && docker-compose up -d
--
-- Add your schema here. Use snake_case for all table and column names.

-- ── Extensions ────────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";    -- uuid_generate_v4()
CREATE EXTENSION IF NOT EXISTS "pgcrypto";     -- gen_random_uuid(), crypt()

-- ── Example Table ─────────────────────────────────────────────────────────────
-- Replace or remove this example with your actual schema.
--
-- CREATE TABLE users (
--     id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--     email       TEXT NOT NULL UNIQUE,
--     created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
--     updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
-- );
--
-- CREATE INDEX idx_users_email ON users(email);

-- ── Notes ─────────────────────────────────────────────────────────────────────
-- - For Supabase projects: use `supabase start` instead of this file
-- - For production migrations: use the /db-migrate command (timestamped SQL + rollback)
-- - RLS policies belong in timestamped migration files, not here
