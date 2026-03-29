# data/ — Data Storage

You are in the **data directory**. Raw and processed data files live here — never committed to git (see `.gitignore`), only referenced.

## Subdirectory Guide

| Directory | Purpose |
|---|---|
| `raw/` | Untouched source data exactly as received — CSV, JSON, API dumps. Never modify files here. |
| `processed/` | Cleaned, transformed outputs from pipeline scripts. Prefer `.parquet` over `.csv` for typed, compressed storage. |

## Rules

- `raw/` is read-only — pipeline scripts read from here, never write back
- Always use relative paths: `data/raw/filename.csv` not absolute paths
- Large files (>50MB): store in cloud storage (S3, GCS, Supabase Storage) and document the location in `docs/guides/data-access.md`
- Never commit real data to git — `.gitignore` excludes `*.csv`, `*.parquet`, `*.pkl` under this directory
- Document the source and acquisition date of every raw file in a `data/raw/README.md` as you add files
