# ops/ — Operations & Infrastructure

You are in the **operations directory**. Everything needed to run, deploy, and monitor the project lives here.

## Subdirectory Guide

| Directory | Purpose |
|---|---|
| `scripts/` | Automation scripts: ETL pipelines, data scrapers, scheduled jobs, bash utilities. Use `snake_case.py` or `kebab-case.sh`. |
| `deploy/` | Deployment configs: `Dockerfile`, `docker-compose.yml`, Vercel config, CI/CD pipeline definitions (GitHub Actions, etc.). |
| `monitoring/` | Logging configs, alerting rules, and observability setup. |

## Rules for This Directory

- Never commit credentials — use environment variables injected at runtime
- All Dockerfiles must use a pinned base image (e.g., `python:3.11-slim`, not `python:latest`)
- Shell scripts must include `set -euo pipefail` at the top
- ETL scripts in `scripts/` should be runnable standalone with clear CLI arguments
- Vercel and deployment configs belong in `deploy/` — not in the project root
- Scripts that modify production data must require explicit confirmation flags (`--confirm`)
