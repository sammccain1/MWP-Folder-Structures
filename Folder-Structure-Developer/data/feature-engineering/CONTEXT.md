# data/feature-engineering/ — Feature Engineering

You are in the **feature-engineering directory**. All code responsible for transforming raw data into model-ready features lives here.

## What Belongs Here

- **Imputation Scripts** — handling missing values, forward-filling, or dropping rows
- **Encoding Scripts** — one-hot encoding, target encoding, or standard scaling
- **Feature Generation** — creating new features (e.g., calculating advanced sports metrics from base box scores)
- **Dataset Splitting** — scripts that segment data into train/validation/test sets

## What Does NOT Belong Here

- **Data Extraction** — pulling raw data belongs in `data/etl-pipelines/`
- **Model Training** — fitting identical models to the engineered data belongs in `src/services/` or `notebooks/`
- **Raw Data** — the input files belong in `data/raw/`

## Naming Convention

```
snake_case.py or snake_case.ts

Examples:
  generate_efficiency_metrics.py
  encode_categorical_variables.py
  create_train_test_split.py
```

## Rules

- **Immutable Inputs**: Feature scripts must read from `data/raw/` but NEVER modify those files.
- **Target `data/processed/`**: Feature engineering outputs (the cleaned, ready-to-train datasets) should be saved to `data/processed/`.
- **Prefer Parquet**: When saving intermediate or final feature sets, prefer `.parquet` format over `.csv` to preserve data types (like datetime) and reduce file size.
- **Track Dependencies**: If a feature script requires another feature script to run first, document this clearly at the top of the file or use an orchestration tool like Dagster/Airflow/Make.
