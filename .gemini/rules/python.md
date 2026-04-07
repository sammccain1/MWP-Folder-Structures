# Python Rules

Stack: Python 3.11+, FastAPI, Scikit-learn, Pandas, Pytest, Pydantic v2

---

## Script Guardrails

```python
# ✅ Every executable script must have a main guard
def main() -> None:
    data = load_data()
    result = process(data)
    save(result)

if __name__ == "__main__":
    main()

# ✅ CLI scripts: explicit exit codes and error messages to stderr
import sys

def main() -> None:
    try:
        run_pipeline()
    except FileNotFoundError as e:
        print(f"[ERROR] Input file not found: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"[ERROR] Pipeline failed: {e}", file=sys.stderr)
        sys.exit(1)
```

---

## Type Hints (Mandatory)

```python
# ✅ Every function: all arguments and return type annotated
from pathlib import Path
from typing import Optional

def load_results(filepath: Path, year: int) -> pd.DataFrame:
    ...

def compute_margin(dem_votes: int, rep_votes: int, total_votes: int) -> float:
    if total_votes == 0:
        raise ValueError("total_votes must be > 0")
    return (dem_votes - rep_votes) / total_votes

def find_winner(margin: float) -> Optional[str]:
    if margin > 0: return "D"
    if margin < 0: return "R"
    return None

# ❌ No bare annotations, no missing return type
def compute_margin(dem, rep, total):   # no types
    return (dem - rep) / total         # no return annotation
```

---

## Pydantic v2 — Data Validation

```python
from pydantic import BaseModel, Field, field_validator, model_validator

class ElectionResult(BaseModel):
    fips: str = Field(min_length=5, max_length=5, pattern=r'^\d{5}$')
    year: int = Field(ge=1900, le=2100)
    dem_votes: int = Field(ge=0)
    rep_votes: int = Field(ge=0)
    total_votes: int = Field(ge=0)

    @field_validator('fips')
    @classmethod
    def fips_must_be_zero_padded(cls, v: str) -> str:
        return v.zfill(5)

    @model_validator(mode='after')
    def votes_must_sum_correctly(self) -> 'ElectionResult':
        if self.dem_votes + self.rep_votes > self.total_votes:
            raise ValueError("dem_votes + rep_votes cannot exceed total_votes")
        return self

# ✅ model_validate (v2 API) not parse_obj (v1)
result = ElectionResult.model_validate(raw_dict)
data_dict = result.model_dump()
```

---

## Mutable Default Arguments

```python
# ❌ Classic Python bug — list is shared across all calls
def add_result(result, results=[]):
    results.append(result)  # mutates the shared default
    return results

# ✅ Use None and create inside function
def add_result(result: dict, results: list | None = None) -> list:
    if results is None:
        results = []
    return [*results, result]  # immutable — return new list
```

---

## FastAPI

```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

router = APIRouter(prefix="/results", tags=["results"])

# ✅ Full correct pattern
@router.get("/{year}", response_model=list[ElectionResultResponse])
async def get_results(
    year: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_auth),
) -> list[ElectionResultResponse]:
    return await results_service.get_by_year(db, year)

@router.post("/", response_model=ElectionResultResponse, status_code=status.HTTP_201_CREATED)
async def create_result(
    payload: ElectionResultCreate,    # ✅ Pydantic model — validates at boundary
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_auth),
) -> ElectionResultResponse:
    return await results_service.create(db, payload)

# Global exception handler — in main app setup
@app.exception_handler(Exception)
async def global_handler(request: Request, exc: Exception):
    logger.error("Unhandled: %s %s — %s", request.method, request.url.path, exc, exc_info=True)
    return JSONResponse(status_code=500, content={"error": "Internal server error"})
```

---

## Machine Learning (Scikit-learn)

```python
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
import joblib

# ✅ Always random_state=42 in all stochastic calls
model = RandomForestClassifier(n_estimators=200, random_state=42)

# ✅ Pass numpy arrays — not raw DataFrames (avoids feature name warnings)
X_train = df_train.drop("target", axis=1).to_numpy()
y_train = df_train["target"].to_numpy()
model.fit(X_train, y_train)

# ✅ Pipeline — fits scaler only on train, transforms test correctly
pipeline = Pipeline([
    ("scaler", StandardScaler()),
    ("model", RandomForestClassifier(n_estimators=200, random_state=42)),
])

# ✅ LOSO CV for sports/temporal data — standard K-fold leaks future data
from sklearn.model_selection import LeaveOneGroupOut
logo = LeaveOneGroupOut()
groups = df["season"].to_numpy()
scores = cross_val_score(pipeline, X, y, cv=logo, groups=groups, scoring="accuracy")

# ✅ Save with version in filename — never overwrite
joblib.dump(pipeline, "models/rf_classifier_v2_20260407.pkl")
```

---

## Error Handling

```python
import logging
logger = logging.getLogger(__name__)

# ✅ Specific exception types — never bare except
try:
    df = pd.read_parquet(filepath)
except FileNotFoundError:
    logger.error("Data file not found: %s", filepath)
    raise
except Exception as e:
    logger.error("Failed to load %s: %s", filepath, e, exc_info=True)
    raise

# ✅ FastAPI: HTTPException for expected client errors
if not user:
    raise HTTPException(status_code=404, detail=f"User {user_id} not found")

# ✅ Pipeline scripts: exit with message on failure
except ValueError as e:
    print(f"[ERROR] Invalid data: {e}", file=sys.stderr)
    sys.exit(1)

# ❌ Never bare except — swallows all errors silently
try:
    process()
except:        # catches SystemExit, KeyboardInterrupt — almost always wrong
    pass
```

---

## Testing (Pytest)

```python
# conftest.py — shared fixtures
import pytest
import pandas as pd

@pytest.fixture
def sample_results() -> pd.DataFrame:
    return pd.DataFrame({
        "fips": ["01001", "01003"],
        "dem_votes": [12_000, 8_000],
        "rep_votes": [8_000, 14_000],
        "total_votes": [20_000, 22_000],
    })

# test_election_service.py — mirrors src/services/election_service.py
def test_compute_margin_dem_win():
    assert compute_margin(60_000, 40_000, 100_000) == pytest.approx(0.20, abs=1e-3)

def test_compute_margin_zero_total_raises():
    with pytest.raises(ValueError, match="total_votes must be > 0"):
        compute_margin(0, 0, 0)

# ✅ Mock external dependencies — never hit real APIs in unit tests
from unittest.mock import patch, MagicMock

def test_fetch_data_handles_timeout():
    with patch("httpx.Client.get", side_effect=httpx.TimeoutException("timeout")):
        with pytest.raises(DataFetchError):
            fetch_external_data()
```

```bash
# Run with coverage
pytest src/tests/ --cov=src --cov-report=term-missing --tb=short -q
```

---

## Security

```python
# ✅ Secrets via environment — never hardcoded
import os
DATABASE_URL = os.environ["DATABASE_URL"]  # raises KeyError if missing — intentional

# ✅ pydantic-settings for typed env config
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    api_key: str
    debug: bool = False

    class Config:
        env_file = ".env"

settings = Settings()  # loads from .env, validates types

# ❌ Never log request bodies — may contain PII or tokens
logger.info("Request body: %s", request_body)   # wrong

# ✅ Log request IDs instead
logger.info("Request %s: POST /api/results", request_id)

# ✅ Pin all dependencies — prevent supply chain attacks
# After: pip install package && pip freeze > requirements.txt
```

---

## Rules Summary

| Rule | Rationale |
|---|---|
| `if __name__ == "__main__":` guard | Prevents execution on import; required for testability |
| Type hints on all signatures | Enables static analysis; mandatory in strict mode |
| Pydantic v2 for validation at boundaries | Catches bad data before it enters the system |
| Never mutable default arguments | Python creates the default once — shared across all calls |
| `random_state=42` everywhere | Reproducible results across runs and environments |
| LOSO CV for temporal/sports data | Standard K-fold leaks future seasons into past folds |
| Pass `.to_numpy()` to sklearn | Avoids feature name warnings; cleaner API surface |
| Never bare `except:` | Catches `SystemExit` and `KeyboardInterrupt` — masks real bugs |
| Secrets via env vars only | Never commit credentials; fail fast if missing |
