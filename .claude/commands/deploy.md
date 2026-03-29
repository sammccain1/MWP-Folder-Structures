---
name: deploy
description: Deployment workflow for Vercel (frontend), FastAPI (backend), and Supabase (database). Use when pushing to staging or production. Enforces pre-deploy checklist, migration safety, and rollback awareness.
allowed_tools: ["Bash", "Read", "Write"]
---

# /deploy

Use this workflow when deploying any part of Sam's stack to staging or production.

## Pre-Deploy Checklist

Before running any deploy command, verify:

- [ ] All tests pass: `pytest` / `npm test`
- [ ] No `.env` secrets committed: `git grep -r "sk_" -- "*.ts" "*.py"`
- [ ] `requirements.txt` or `environment.yml` is pinned (no `>=` without upper bound on critical deps)
- [ ] DB migrations are non-breaking (no column drops without a prior deploy cycle)
- [ ] `task.md` reflects current state

## Deployment Targets

### Vercel (Next.js Frontend)
```bash
# Staging
vercel --env preview

# Production
vercel --prod
```
- Vercel config lives in `ops/deploy/vercel.json`
- Env vars set in Vercel dashboard — never in repo
- Check build logs before marking done

### FastAPI Backend (Docker)
```bash
# Build
docker build -t mwp-api:latest -f ops/deploy/Dockerfile .

# Run locally to verify
docker run --env-file .env -p 8000:8000 mwp-api:latest

# Push to registry
docker tag mwp-api:latest registry/mwp-api:$(git rev-parse --short HEAD)
docker push registry/mwp-api:$(git rev-parse --short HEAD)
```

### Supabase Migrations
```bash
# Always: local → staging → production
supabase db reset        # verify locally first
supabase db push         # push to linked project

# Verify RLS policies applied
supabase db diff
```

## Rollback Plan

Every deploy must have a rollback path defined before executing:

| Target | Rollback Method |
|---|---|
| Vercel | Promote previous deployment from dashboard |
| Docker | `docker pull registry/mwp-api:[previous-sha]` |
| Supabase | Revert migration (write inverse SQL first) |

## Post-Deploy Verification

1. Hit the health endpoint: `curl https://[domain]/api/health`
2. Check logs for 5xx errors
3. Smoke test critical user flows manually
4. Update `task.md` — mark deploy complete

## Notes

- Never deploy to production without staging validation first
- Database migrations deploy before code changes, not after
- If rollback is needed: stop, rollback, then diagnose — don't patch forward under pressure