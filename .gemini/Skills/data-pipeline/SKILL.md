---
name: data-pipeline
description: ETL and data pipeline patterns for Sam's projects. Load when building scrapers, scheduled fetch scripts, or multi-step data transformation pipelines. Covers fetch → clean → store patterns, scheduling, idempotency, error handling, and scraping conventions for sports and political data sources.
---

# Data Pipeline Skill

ETL patterns for fetch → clean → store pipelines. Optimised for the sports analytics and political data sources in Sam's actual workload.

---

## Pipeline Directory Layout

```
ops/
  scripts/
    fetch_<source>.py       # acquire raw data
    clean_<source>.py       # validate and clean
    schedule.py             # orchestrate (cron / schedule lib)
data/
  raw/                      # immutable source data — never modified
  processed/                # cleaned, ready-to-use
  archive/                  # old versions (YYYY-MM-DD prefix)
```

**Rule:** `data/raw/` is write-once. Never overwrite a raw file — archive and create a new dated version.

---

## Fetch Script Template

```python
"""
ops/scripts/fetch_<source>.py
Fetch raw data from <source> and save to data/raw/.
Idempotent: safe to re-run — will not overwrite if today's file exists.
"""
import requests
import pandas as pd
from pathlib import Path
from datetime import date
import logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)

RAW_DIR = Path("data/raw")
RAW_DIR.mkdir(parents=True, exist_ok=True)

BASE_URL = "https://api.example.com/v1/endpoint"
HEADERS = {"User-Agent": "MWP-Pipeline/1.0 (contact@example.com)"}


def fetch(season: int) -> pd.DataFrame:
    """Fetch data for a single season. Returns raw DataFrame."""
    url = f"{BASE_URL}?season={season}"
    log.info(f"Fetching: {url}")

    response = requests.get(url, headers=HEADERS, timeout=30)
    response.raise_for_status()

    data = response.json()
    return pd.DataFrame(data)


def save_raw(df: pd.DataFrame, source: str) -> Path:
    """Save raw data with date-stamped filename. Skips if exists (idempotent)."""
    today = date.today().isoformat()
    path = RAW_DIR / f"{today}_{source}.csv"

    if path.exists():
        log.info(f"Already exists, skipping: {path}")
        return path

    df.to_csv(path, index=False)
    log.info(f"Saved {len(df)} rows → {path}")
    return path


if __name__ == "__main__":
    df = fetch(season=2026)
    save_raw(df, source="kenpom")
```

---

## Clean Script Template

```python
"""
ops/scripts/clean_<source>.py
Validate and clean raw data. Input: data/raw/, Output: data/processed/.
"""
import pandas as pd
from pathlib import Path
import logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)

RAW_DIR = Path("data/raw")
PROCESSED_DIR = Path("data/processed")
PROCESSED_DIR.mkdir(parents=True, exist_ok=True)

REQUIRED_COLS = ["team", "season", "adj_em", "seed"]


def validate(df: pd.DataFrame) -> pd.DataFrame:
    """Raise on schema violations. Return df if valid."""
    missing = [c for c in REQUIRED_COLS if c not in df.columns]
    if missing:
        raise ValueError(f"Missing required columns: {missing}")

    null_counts = df[REQUIRED_COLS].isnull().sum()
    if null_counts.any():
        log.warning(f"Nulls found:\n{null_counts[null_counts > 0]}")

    return df


def clean(df: pd.DataFrame) -> pd.DataFrame:
    """Apply cleaning transforms. Returns new DataFrame (never mutates input)."""
    df = df.copy()

    # Normalise column names
    df.columns = [c.strip().lower().replace(" ", "_") for c in df.columns]

    # Drop exact duplicates
    n_before = len(df)
    df = df.drop_duplicates()
    log.info(f"Dropped {n_before - len(df)} duplicate rows")

    # Coerce numeric columns
    for col in ["adj_em", "seed", "win_rate"]:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce")

    return df


if __name__ == "__main__":
    raw_files = sorted(RAW_DIR.glob("*_kenpom.csv"))
    if not raw_files:
        raise FileNotFoundError("No raw kenpom files found in data/raw/")

    latest = raw_files[-1]
    log.info(f"Processing: {latest}")

    raw = pd.read_csv(latest)
    validated = validate(raw)
    cleaned = clean(validated)

    out_path = PROCESSED_DIR / f"{latest.stem}_processed.parquet"
    cleaned.to_parquet(out_path, index=False)
    log.info(f"Saved {len(cleaned)} rows → {out_path}")
```

---

## Scheduling

### Simple (schedule library)

```python
# ops/scripts/schedule.py
import schedule
import time
import subprocess
import logging

log = logging.getLogger(__name__)

def run_pipeline():
    log.info("Running daily ETL pipeline...")
    subprocess.run(["python", "ops/scripts/fetch_kenpom.py"], check=True)
    subprocess.run(["python", "ops/scripts/clean_kenpom.py"], check=True)
    log.info("Pipeline complete.")

schedule.every().day.at("06:00").do(run_pipeline)

if __name__ == "__main__":
    log.info("Scheduler started.")
    while True:
        schedule.run_pending()
        time.sleep(60)
```

### Cron (macOS launchd or system cron)

```bash
# Add to crontab: crontab -e
0 6 * * * cd /path/to/project && python ops/scripts/schedule.py >> logs/cron.log 2>&1
```

---

## Scraping Conventions

```python
import time
import random
import requests
from bs4 import BeautifulSoup

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 Chrome/120 Safari/537.36"
    )
}

def scrape_page(url: str) -> BeautifulSoup:
    """Polite scraper — respects rate limits."""
    time.sleep(random.uniform(1.5, 3.0))   # never hammer a server
    resp = requests.get(url, headers=HEADERS, timeout=20)
    resp.raise_for_status()
    return BeautifulSoup(resp.text, "html.parser")
```

**Rules:**
- Always `time.sleep(1.5–3.0)` between requests
- Always set a descriptive `User-Agent`
- Check `robots.txt` before scraping — `requests.get(base_url + "/robots.txt")`
- Never scrape in parallel without explicit permission from the site owner

---

## Idempotency Checklist

Before shipping any pipeline, verify:

- [ ] Re-running fetch does not overwrite existing raw files (date-stamp check)
- [ ] Re-running clean does not produce different output from the same input
- [ ] Pipeline handles missing data gracefully (log + skip, never crash silently)
- [ ] All intermediate files have date stamps in their names
- [ ] `data/raw/` is in `.gitignore` (large files) — with explicit exceptions for small reference CSVs

---

## Common Issues

| Issue | Root Cause | Fix |
|---|---|---|
| DataFrame index in parquet differs from CSV | `index=True` default | Always `to_parquet(..., index=False)` |
| Silent null injection on `pd.to_numeric` | Non-numeric strings | Log null counts after coercion |
| API rate limit (429) | Too many requests | Add exponential backoff + jitter |
| Column name mismatch between seasons | Source API changed | Validate against `REQUIRED_COLS` before cleaning |
| Duplicate rows after join | Many-to-many on key | Audit join keys before merging |
