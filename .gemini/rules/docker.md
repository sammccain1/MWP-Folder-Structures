# Docker Rules

Guardrails for all Dockerfiles and `docker-compose.yml` files in `ops/deploy/`.

---

## Base Images

```dockerfile
# ✅ Always pin exact version tags — never use latest
FROM python:3.11-slim
FROM node:20-alpine
FROM postgres:16-alpine

# ❌ Never do this
FROM python:latest
FROM node
```

**Rule:** Use `-slim` (Debian) or `-alpine` variants to minimize attack surface and image size.

---

## Multi-Stage Builds (Required for Next.js)

```dockerfile
# ── Stage 1: Build ────────────────────────────────────────────────────────────
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --frozen-lockfile
COPY . .
RUN npm run build

# ── Stage 2: Run ──────────────────────────────────────────────────────────────
FROM node:20-alpine AS runner
ENV NODE_ENV=production
WORKDIR /app
# Only copy the built output — not source, not node_modules
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
EXPOSE 3000
CMD ["node", "server.js"]
```

---

## Non-Root User (Required)

```dockerfile
# ✅ Never run as root in production containers
FROM python:3.11-slim

# Create a non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

WORKDIR /app
COPY --chown=appuser:appgroup requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY --chown=appuser:appgroup . .

USER appuser  # ← switch to non-root before CMD
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## Dependency Installation

```dockerfile
# ✅ Copy dependency files first — maximizes layer cache reuse
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .   # ← source changes don't invalidate the pip layer

# ✅ Use --frozen-lockfile / --no-cache to ensure reproducible builds
RUN npm ci --frozen-lockfile
RUN pip install --no-cache-dir -r requirements.txt
```

---

## Environment Variables

```dockerfile
# ✅ Set non-sensitive runtime config in Dockerfile
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    NODE_ENV=production

# ❌ Never hardcode secrets in Dockerfile
ENV API_KEY=sk-abc123   # ← commits secret to image layers — NEVER do this
```

**Pass secrets at runtime:**
```bash
docker run --env-file .env my-image
# or via docker-compose: env_file: [.env]
```

---

## .dockerignore (Required)

Every project with a Dockerfile must have a `.dockerignore`:

```
# Dependencies
node_modules/
__pycache__/
*.pyc
.venv/

# Git
.git/
.gitignore

# Dev artifacts
.env
.env.local
*.log
.DS_Store

# Test artifacts
coverage/
.pytest_cache/
```

---

## docker-compose Rules

```yaml
services:
  api:
    build:
      context: .
      dockerfile: ops/deploy/Dockerfile  # ✅ explicit path
    ports:
      - "8000:8000"
    env_file: [.env]                     # ✅ secrets from file, not inline
    depends_on:
      db:
        condition: service_healthy       # ✅ wait for healthcheck, not just started
    restart: unless-stopped

  db:
    image: postgres:16-alpine           # ✅ pinned
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
```

---

## Rules Summary

| Rule | Rationale |
|---|---|
| Pin all base image tags | Reproducible builds; avoid surprise breaking changes |
| Use multi-stage builds for Next.js | Separates build tools from runtime; smaller final image |
| Run as non-root user | Limits blast radius if container is compromised |
| Copy deps before source | Maximizes Docker layer caching speed |
| Use `.dockerignore` | Prevents secrets and build artifacts entering the image |
| Never hardcode secrets in Dockerfile | Secrets persist in image layers even if overwritten |
| Use `healthcheck` in compose | Prevents dependent services starting before DB is ready |
