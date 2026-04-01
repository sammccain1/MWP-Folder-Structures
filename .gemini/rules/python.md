# Python Rules

Stack: Python 3.11+, Scikit-learn, Pandas, Pytest

## General Guardrails

- `set -euo pipefail` equivalent: always use `if __name__ == "__main__":` guards for executable scripts
- Virtual env discipline: always check `which python` or verify you are in `.venv/` before running pip installs or executing code
- Type hints are mandatory for all function arguments and return types

## Pandas / Data Manipulation

- **Never use `.inplace=True`** — always assign to a new variable (e.g., `df = df.dropna()`)
- Use `.copy()` when slicing DataFrames to avoid `SettingWithCopyWarning`
- Avoid `for` loops over DataFrame rows. Use vectorized operations, `.apply()`, or list comprehensions

## Machine Learning (Scikit-learn)

- **Always `random_state=42`** in stochastic sklearn calls (train_test_split, RandomForest, KFold, etc.) to ensure reproducibility
- Pass numpy arrays (e.g., `X.to_numpy()`) instead of DataFrames to `model.fit()` and `model.predict()` to avoid sklearn feature name warnings
- Never leak data: fit imputers and scalers ONLY on the training fold, then transform the test fold
