# Pandas Rules

Guardrails for all Pandas usage in Python data pipelines, ETL scripts, and ML feature engineering.

---

## Never Mutate In Place

```python
# ✅ Always assign to a new variable
df_clean = df.dropna(subset=["fips", "total_votes"])
df_typed = df_clean.astype({"fips": str, "total_votes": int})

# ❌ Never use inplace=True — hides bugs, prevents chaining, returns None
df.dropna(inplace=True)      # returns None — easy to lose track of state
df.rename(columns={...}, inplace=True)
```

---

## Use .loc / .iloc for Indexing — Never Chained

```python
# ✅ Single indexing operation — avoids SettingWithCopyWarning
df.loc[df["state"] == "CA", "margin"] = df["dem_votes"] / df["total_votes"]

# ✅ iloc for positional access
first_row = df.iloc[0]
top_10 = df.iloc[:10]

# ❌ Never chain indexing — raises SettingWithCopyWarning and may silently fail
df[df["state"] == "CA"]["margin"] = 0.5   # modifies a copy, not the original
```

---

## dtypes — Be Explicit

```python
# ✅ Set dtypes on read — don't let Pandas guess
df = pd.read_csv(
    "data/raw/election_results.csv",
    dtype={
        "fips": str,          # FIPS codes must be strings (zero-padded)
        "total_votes": int,
        "dem_votes": int,
    },
    parse_dates=["election_date"],
)

# ✅ Cast explicitly when building DataFrames
df["margin"] = df["margin"].astype(float)
df["fips"] = df["fips"].str.zfill(5)      # ensure 5-digit zero-padding
```

---

## Avoid Loops — Vectorize

```python
# ✅ Vectorized operations — fast, readable
df["margin"] = df["dem_votes"] / df["total_votes"] - df["rep_votes"] / df["total_votes"]
df["winner"] = df["margin"].apply(lambda x: "D" if x > 0 else "R")  # apply for row-level logic

# ✅ Use np.where for if/else
import numpy as np
df["winner"] = np.where(df["margin"] > 0, "D", "R")

# ❌ Never loop over rows — 100-1000x slower
for i, row in df.iterrows():
    df.at[i, "margin"] = row["dem_votes"] / row["total_votes"]  # extremely slow
```

---

## Merging / Joining

```python
# ✅ Validate merge results — catch unexpected row count changes
before = len(df_left)
merged = df_left.merge(df_right, on="fips", how="left", validate="many_to_one")
after = len(merged)
assert before == after, f"Merge duplicated rows: {before} -> {after}"

# ✅ Use validate= parameter to catch cardinality bugs
df.merge(lookup, on="id", how="left", validate="many_to_one")
# Options: "one_to_one", "one_to_many", "many_to_one", "many_to_many"
```

---

## Memory Management

```python
# ✅ Use appropriate dtypes to reduce memory
df["state_fips"] = df["state_fips"].astype("category")   # for low-cardinality strings
df["year"] = df["year"].astype("int16")                   # if values fit in int16

# ✅ Check memory usage
print(df.memory_usage(deep=True).sum() / 1e6, "MB")

# ✅ Read large CSVs in chunks
chunks = []
for chunk in pd.read_csv("big_file.csv", chunksize=100_000):
    chunks.append(process(chunk))
df = pd.concat(chunks, ignore_index=True)

# ✅ Prefer Parquet over CSV for large files (preserves dtypes, 5-10x smaller)
df.to_parquet("data/processed/results.parquet", index=False)
df = pd.read_parquet("data/processed/results.parquet")
```

---

## GroupBy & Aggregation

```python
# ✅ Name aggregation columns explicitly with named aggregation
state_summary = df.groupby("state").agg(
    total_votes=("total_votes", "sum"),
    dem_votes=("dem_votes", "sum"),
    n_counties=("fips", "count"),
).reset_index()

# ✅ Add margin after aggregation
state_summary["margin"] = (
    state_summary["dem_votes"] / state_summary["total_votes"]
)
```

---

## Handling Missing Data

```python
# ✅ Inspect before dropping
print(df.isnull().sum())           # count NaN per column
print(df[df["fips"].isnull()])     # inspect rows with missing FIPS

# ✅ Drop only after understanding why
df_clean = df.dropna(subset=["fips", "total_votes"])

# ✅ Fill with a meaningful default or flag
df["incumbent"] = df["incumbent"].fillna(False)
```

---

## Rules Summary

| Rule | Rationale |
|---|---|
| Never `inplace=True` | Returns `None`, hides bugs, prevents chaining |
| Always `.loc`/`.iloc` for assignment | Avoids `SettingWithCopyWarning` and silent copy mutations |
| Explicit `dtype=` on read | Prevents FIPS/zip code truncation and type coercion bugs |
| Vectorize over `iterrows` | 100-1000x faster on real datasets |
| Validate merge row counts | Catches unintended duplication from bad join keys |
| Prefer Parquet over CSV | Preserves dtypes, faster I/O, smaller file size |
