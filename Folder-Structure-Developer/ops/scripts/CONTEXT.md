# ops/scripts/ — Automation Scripts & Utilities

You are in the **scripts directory**. All automation scripts, bash utilities, and scheduled job entrypoints live here.

## What Belongs Here

- **ETL job runners** — production entrypoints that call pipeline logic from `data/etl-pipelines/`
- **Data scrapers** — standalone scripts that fetch from external APIs or sites
- **Scheduled jobs** — cron-compatible scripts designed to run on a schedule (Celery, GitHub Actions, etc.)
- **Database utilities** — `init.sql` seeds, migration helpers, backup scripts
- **Bash utilities** — `set-up-env.sh`, `seed-db.sh`, `run-pipeline.sh`

## What Does NOT Belong Here

- Notebook-style exploratory scripts — those go in `notebooks/`
- Production application logic — that goes in `src/services/`
- Feature engineering code — that goes in `data/feature-engineering/`

## Naming Convention

```
Python scripts:  snake_case.py
Shell scripts:   kebab-case.sh
SQL scripts:     YYYY-MM-DD_description.sql  (migrations)
                 snake_case.sql              (utilities)

Examples:
  scrape_kenpom.py
  run-etl-pipeline.sh
  seed-dev-db.sh
  init.sql
```

## Rules

- All shell scripts must begin with `set -euo pipefail`
- Scripts must be runnable standalone with clear CLI arguments — use `argparse` (Python) or `getopts` (bash)
- Scripts that **write to production data** must require an explicit `--confirm` flag
- Scripts should be **idempotent** — safe to re-run without corrupting state
- Never hardcode credentials — use environment variables from `.env`
- Scheduled jobs: document the expected cron schedule in a comment at the top of the file
