# Python Rules

Stack: Python 3.11+, FastAPI, Scikit-learn, Pandas, Pytest, Pydantic

## Script Guardrails

- Always use `if __name__ == "__main__":` guards on executable scripts — never bare top-level execution
- Virtual env discipline: verify `which python` resolves to `.venv/bin/python` before any `pip install`
- `set -euo pipefail` equivalent in Python: wrap `main()` in `try/except` with explicit exit codes for CLI scripts
- Type hints mandatory on all function signatures: arguments and return types, no exceptions
- Never use mutable default arguments: `def fn(x, items=[])` → `def fn(x, items=None): items = items or []`

## FastAPI

- All route handlers must have explicit `response_model` — never return raw dicts from typed endpoints
- Use `Depends()` for auth injection — never read `Authorization` headers manually inside handlers
- Validate all inputs with Pydantic models at the boundary — never trust `dict` from request body
- Async routes (`async def`) for any I/O operation — DB, HTTP, file reads
- No business logic in route handlers — delegate to `src/services/`
- Global exception handler must catch unhandled errors and return `{ "error": "Internal server error" }` with 500

```python
# ✅ Correct
@router.post("/users", response_model=UserResponse)
async def create_user(
    payload: UserCreateRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_auth),
) -> UserResponse:
    return await user_service.create(db, payload)
```

## Pandas / Data Manipulation

- **Never `.inplace=True`** — always assign: `df = df.dropna()` not `df.dropna(inplace=True)`
- Use `.copy()` when slicing to avoid `SettingWithCopyWarning`
- No `for` loops over DataFrame rows — use vectorized ops, `.apply()`, or list comprehensions
- `read_sql()` only with parameterized queries — never string-concat SQL
- Prefer `.parquet` over `.csv` for intermediate pipeline outputs (typed, compressed, faster R interop)

## Machine Learning (Scikit-learn)

- **Always `random_state=42`** in all stochastic calls: `train_test_split`, `RandomForest`, `KFold`, etc.
- Pass `X.to_numpy()` to `model.fit()` / `model.predict()` — not raw DataFrames (avoids feature name warnings)
- **Never leak data**: fit scalers and imputers ONLY on the training fold, then `.transform()` the test fold
- For temporal/sports data: use LOSO (Leave-One-Season-Out) CV — standard K-fold leaks future data
- Save models with joblib: `joblib.dump(model, "models/name_vN.pkl")` — version the filename

## Error Handling

- Use specific exception types — never bare `except:` or `except Exception:` without re-raise or logging
- Log errors with context: `logger.error("Failed to process %s: %s", item_id, e, exc_info=True)`
- FastAPI endpoints: `HTTPException` for expected errors (400/401/404), let unhandled propagate to global handler
- Pipeline scripts: exit non-zero on failure — `sys.exit(1)` with a clear error message to stderr

## Testing (Pytest)

- Test files mirror `src/` structure: `src/services/user.py` → `src/tests/test_user.py`
- Minimum 80% coverage on `src/services/` and `src/utils/`
- Use `pytest.fixture` for shared state — never `setUp`/`tearDown` style
- Mock external calls: never hit real APIs, databases, or filesystems in unit tests
- `conftest.py` at `src/tests/` root for shared fixtures

## Security

- All SQL via parameterized queries or ORM — no f-strings in SQL ever
- Secrets via environment variables only — `os.environ["KEY"]` or `pydantic-settings`
- Never log request bodies — may contain PII or tokens
- Pin all dependencies in `requirements.txt` — `pip freeze > requirements.txt` after install
