# data/ — Data Storage

You are in the **data directory**. Raw, interim, and processed data files live here — never committed to git (see `.gitignore`), only referenced.

## Subdirectory Guide

| Directory | Purpose |
|---|---|
| `raw/` | Untouched source data exactly as received — CSV, JSON, API dumps. **Never modify files here.** Document each file in `raw/README.md`. |
| `processed/` | Cleaned, transformed outputs from pipeline scripts. Prefer `.parquet` over `.csv` for typed, compressed storage. |
| `etl-pipelines/` | ETL extraction and loading scripts — Python or SQL that pulls from external sources and lands data in `raw/` or a database. |
| `feature-engineering/` | Feature transformation scripts and intermediate outputs — reads from `raw/` or `processed/`, outputs feature sets for model training. |

## Data Flow

```
External Source
      ↓  (etl-pipelines/)
  data/raw/           ← read-only after landing
      ↓  (feature-engineering/)
  data/processed/     ← clean, typed, model-ready
      ↓
  models/             ← training input
```

## Rules

- `raw/` is **read-only** — pipeline scripts read from here, never write back
- Always use relative paths: `data/raw/filename.csv` not absolute paths
- Large files (>50MB): store in cloud storage (S3, GCS, Supabase Storage) and document the location in `data/raw/README.md`
- Never commit real data to git — `.gitignore` excludes `*.csv`, `*.parquet`, `*.pkl` under this directory
- ETL and feature scripts belong in `etl-pipelines/` and `feature-engineering/` — production scheduled jobs go in `ops/scripts/`
- Document the source and acquisition date of every raw file in `data/raw/README.md`
