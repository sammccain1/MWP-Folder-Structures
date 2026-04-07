# data/etl-pipelines/ — Data Extraction & Loading

You are in the **etl-pipelines directory**. All code responsible for fetching external data and landing it in the project lives here.

## What Belongs Here

- **API Extractors** — scripts that hit external endpoints (e.g., KenPom, NOAA, Twitter) and dump JSON/CSV
- **Web Scrapers** — BeautifulSoup, Playwright, or Scrapy scripts mapping HTML to structured data
- **Database Importers** — scripts that move data from upstream databases into the local `data/raw/` folder or local PostgreSQL
- **Format Converters** — scripts that convert raw XML/JSON streams into tabular formats

## What Does NOT Belong Here

- **Feature Engineering** — creating model-ready features from raw data belongs in `data/feature-engineering/`
- **Model Training** — training logic belongs in `src/services/` or `notebooks/`
- **Production Scheduled Jobs** — the actual cron wrappers or entrypoints that run the ETL pipelines in production belong in `ops/scripts/`

## Naming Convention

```
snake_case.py or snake_case.ts

Examples:
  extract_kenpom_data.py
  scrape_election_results.js
```

## Rules

- **Idempotency is mandatory**: ETL scripts must be safe to run multiple times without duplicating data or breaking state. (Use upserts, or truncate-and-load).
- **Target `data/raw/`**: ETL scripts should output their results into `data/raw/` (or a database), never straight to `data/processed/` or `models/`.
- **Handle failures gracefully**: Implement retry logic for API calls using backoff strategies.
- **Separate E from L**: Keep extraction logic (fetching) separate from load logic (saving), to make the code easier to test.
