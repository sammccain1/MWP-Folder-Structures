---
name: deploy
description: Pre-flight checks and deployment process. Run this before deploying to production.
allowed_tools: ["Bash", "Read"]
---

# /deploy

Run this before any deployment to production.

## Step 1 — Pre-Flight Review

```bash
/review
```
A deployment must not happen if any pre-delivery checks fail. Ensure tests, linting, and accessibility passes.

## Step 2 — Ensure Main is Sync'd

```bash
git checkout main
git pull origin main
```

## Step 3 — Build

```bash
npm run build
```

## Step 4 — Deploy

```bash
# Example
vercel --prod
# Or docker compose up -d --build
```

## Step 5 — Rollback Plan

If the deployment fails or causes critical errors, immediately execute the rollback plan.

**Git Rollback:**
```bash
# Identify the last known good commit
git log --oneline

# Option A: Revert the broken commit (safe for shared branches)
git revert <bad-commit-hash>
git push origin main

# Option B: Hard reset (only if absolutely necessary and branch rules allow)
git reset --hard <good-commit-hash>
git push origin main --force
```

**Docker Rollback:**
```bash
# If using Docker tags, redeploy the previous image tag
docker stop <container>
docker run -d --name <container> <image>:<previous-tag>
```

**Vercel Rollback:**
- Log into the Vercel dashboard, navigate to the specific project deployments tab, find the previous successful deployment, and click "Promote to Production".