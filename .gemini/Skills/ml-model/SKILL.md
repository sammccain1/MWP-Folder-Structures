---
name: ml-model
description: End-to-end ML model patterns for Sam's projects. Load when building, evaluating, or versioning a scikit-learn model. Covers feature engineering conventions, cross-validation strategies (including LOSO), metric selection, model serialisation, and anti-patterns observed in real projects.
---

# ML Model Skill

Scikit-learn patterns for the full model lifecycle: train → evaluate → version → deploy. Based on actual mistakes and wins from Sam's bracket sim and sports analytics work.

---

## Project Layout

```
src/
  preprocess.py     # raw → clean DataFrame
  features.py       # clean → feature matrix + target
  train.py          # fit model, save to models/
  evaluate.py       # load model, produce metrics + figures
  predict.py        # load model, produce predictions
tests/
  test_preprocess.py
  test_features.py
  test_train.py
models/
  model_name_v1.pkl
  model_name_v1_metadata.json
data/
  raw/
  processed/
```

---

## Feature Engineering

```python
import pandas as pd
import numpy as np

def build_features(df: pd.DataFrame) -> tuple[pd.DataFrame, pd.Series]:
    """
    Returns (X, y) — feature matrix and target.
    Always use a numpy array for X to avoid sklearn feature name warnings.
    """
    FEATURES = [
        "adj_em",        # KenPom adjusted efficiency margin
        "seed",
        "sos",           # strength of schedule
        "barthag",       # power rating
        "win_rate",
    ]
    TARGET = "made_sweet_16"

    # Fill missing values BEFORE split — never after
    df = df.copy()
    df[FEATURES] = df[FEATURES].fillna(df[FEATURES].median())

    X = df[FEATURES].to_numpy()           # numpy array avoids UserWarning
    y = df[TARGET].to_numpy()
    feature_names = FEATURES              # keep for post-hoc analysis
    return X, y, feature_names
```

**Rules:**
- `random_state=42` everywhere — reproducibility is non-negotiable
- Fill nulls before train/test split, not after
- Return numpy arrays from `build_features()` to silence sklearn warnings
- Store `feature_names` separately for SHAP / feature importance plots

---

## Cross-Validation Strategies

### Standard k-fold (small datasets)
```python
from sklearn.model_selection import cross_val_score, StratifiedKFold

cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
scores = cross_val_score(model, X, y, cv=cv, scoring="roc_auc")
print(f"AUC: {scores.mean():.3f} ± {scores.std():.3f}")
```

### Leave-One-Season-Out (LOSO) — for temporal sports data
```python
def loso_cv(df: pd.DataFrame, model, X: np.ndarray, y: np.ndarray) -> list[dict]:
    """
    Leave one season out — critical for sports models to avoid data leakage.
    Seasons in chronological order; each season is a test fold once.
    """
    seasons = sorted(df["season"].unique())
    results = []

    for test_season in seasons:
        mask = df["season"] == test_season
        X_train, X_test = X[~mask], X[mask]
        y_train, y_test = y[~mask], y[mask]

        model.fit(X_train, y_train)
        probs = model.predict_proba(X_test)[:, 1]

        from sklearn.metrics import roc_auc_score
        auc = roc_auc_score(y_test, probs) if y_test.sum() > 0 else float("nan")
        results.append({"season": test_season, "auc": auc, "n_test": mask.sum()})

    return results
```

> **LOSO is mandatory for any model trained on historical sports seasons.** Standard k-fold leaks future data into past folds.

---

## Metric Selection

| Task | Primary Metric | Secondary |
|---|---|---|
| Classification (balanced) | AUC-ROC | F1 |
| Classification (imbalanced) | Recall@K | Precision@K |
| Tournament bracket | Recall@16, Recall@32 | AUC-ROC |
| Regression | RMSE | MAE |

### Recall@K (tournament-specific)
```python
def recall_at_k(y_true: np.ndarray, probs: np.ndarray, k: int) -> float:
    """Fraction of true positives captured in top-k predictions."""
    top_k_idx = np.argsort(probs)[::-1][:k]
    return y_true[top_k_idx].sum() / y_true.sum()
```

---

## Model Serialisation

```python
import pickle
import json
from datetime import date

def save_model(model, feature_names: list, metrics: dict, name: str, version: int):
    """Save model + metadata atomically."""
    import os
    os.makedirs("models", exist_ok=True)

    model_path = f"models/{name}_v{version}.pkl"
    meta_path  = f"models/{name}_v{version}_metadata.json"

    with open(model_path, "wb") as f:
        pickle.dump(model, f)

    metadata = {
        "name": name,
        "version": version,
        "date": str(date.today()),
        "features": feature_names,
        "metrics": metrics,
        "sklearn_version": __import__("sklearn").__version__,
    }
    with open(meta_path, "w") as f:
        json.dump(metadata, f, indent=2)

    print(f"Saved: {model_path}")
    print(f"Saved: {meta_path}")


def load_model(name: str, version: int):
    with open(f"models/{name}_v{version}.pkl", "rb") as f:
        return pickle.load(f)
```

**Versioning rules:**
- Increment version on any feature set change, not just hyperparameter changes
- Always save `_metadata.json` alongside the pickle
- Never load a model whose `sklearn_version` differs by a minor version (e.g., 1.3 vs 1.4) without retraining

---

## Training Scaffold

```python
from sklearn.ensemble import RandomForestClassifier
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

def build_model() -> Pipeline:
    return Pipeline([
        ("scaler", StandardScaler()),
        ("clf", RandomForestClassifier(
            n_estimators=500,
            max_depth=None,
            min_samples_leaf=2,
            random_state=42,
            n_jobs=-1,
        )),
    ])

if __name__ == "__main__":
    df = pd.read_parquet("data/processed/season_data.parquet")
    X, y, feature_names = build_features(df)

    model = build_model()
    model.fit(X, y)

    metrics = {"auc": cross_val_score(model, X, y, cv=5, scoring="roc_auc").mean()}
    save_model(model, feature_names, metrics, name="bracket_model", version=1)
```

---

## Anti-Patterns

| Anti-Pattern | Why It's Wrong | Fix |
|---|---|---|
| `train_test_split` on temporal data | Leaks future seasons into past | Use LOSO |
| Fitting imputer on full dataset | Leaks test statistics into train | Fit imputer only on train fold |
| Forgetting `random_state` | Non-reproducible results | Add `random_state=42` to every stochastic step |
| Using `accuracy` on imbalanced targets | Misleading (64-team bracket: 97% "no") | Use AUC-ROC or Recall@K |
| Saving only the pickle, not metadata | Can't reproduce model later | Always save `_metadata.json` |
| Using feature names from DataFrame in sklearn | UserWarning in newer sklearn | Pass numpy array, store names separately |
