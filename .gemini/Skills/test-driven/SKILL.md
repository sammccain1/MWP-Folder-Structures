---
name: test-driven
description: TDD red-green-refactor workflow for Python (pytest) and TypeScript (Jest/Vitest). Covers writing failing tests first, mocking strategies, fixture patterns, and coverage enforcement. Load when writing any new service, utility, or pipeline function.
---

# Test-Driven Development Skill

Red-green-refactor workflow and mocking patterns for Python and TypeScript.

---

## The Cycle

```
1. RED   — Write a failing test that describes the desired behavior
2. GREEN — Write the minimum code to make it pass
3. REFACTOR — Clean up without breaking the test
```

Never write implementation code before a failing test exists.

---

## Python — pytest

### Basic Structure

```python
# src/tests/services/test_election_service.py
import pytest
from src.services.election_service import compute_margin

def test_compute_margin_dem_win():
    result = compute_margin(dem_votes=60_000, rep_votes=40_000, total_votes=100_000)
    assert result == pytest.approx(0.20, abs=0.001)

def test_compute_margin_rep_win():
    result = compute_margin(dem_votes=40_000, rep_votes=60_000, total_votes=100_000)
    assert result == pytest.approx(-0.20, abs=0.001)

def test_compute_margin_zero_total_votes():
    with pytest.raises(ValueError, match="total_votes must be > 0"):
        compute_margin(dem_votes=0, rep_votes=0, total_votes=0)
```

### Fixtures

```python
# conftest.py — shared fixtures available to all tests
import pytest
import pandas as pd

@pytest.fixture
def sample_results_df():
    return pd.DataFrame({
        "fips": ["01001", "01003"],
        "dem_votes": [12_000, 8_000],
        "rep_votes": [8_000, 14_000],
        "total_votes": [20_000, 22_000],
    })

# Use in test
def test_process_results(sample_results_df):
    result = process_results(sample_results_df)
    assert len(result) == 2
    assert "margin" in result.columns
```

### Mocking External APIs

```python
from unittest.mock import patch, MagicMock

def test_fetch_kenpom_data():
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.json.return_value = [{"team": "Duke", "adj_em": 32.5}]

    with patch("requests.get", return_value=mock_response):
        result = fetch_kenpom_data(year=2026)
        assert len(result) == 1
        assert result[0]["team"] == "Duke"
```

### Running Tests

```bash
# Run all tests with coverage
pytest src/tests/ --cov=src --cov-report=term-missing --tb=short

# Run a specific test file
pytest src/tests/services/test_election_service.py -v

# Run tests matching a keyword
pytest -k "test_compute_margin" -v

# Stop after first failure
pytest -x
```

---

## TypeScript — Jest / Vitest

### Basic Structure

```typescript
// src/tests/utils/formatters.test.ts
import { formatMargin } from '@/utils/formatters'

describe('formatMargin', () => {
  it('formats positive margin as D+', () => {
    expect(formatMargin(0.123)).toBe('D+12.3%')
  })

  it('formats negative margin as R+', () => {
    expect(formatMargin(-0.073)).toBe('R+7.3%')
  })

  it('formats zero margin as EVEN', () => {
    expect(formatMargin(0)).toBe('EVEN')
  })
})
```

### Mocking API Calls

```typescript
// Mock fetch globally in test setup
global.fetch = jest.fn()

describe('fetchElectionResults', () => {
  beforeEach(() => {
    (fetch as jest.Mock).mockResolvedValue({
      ok: true,
      json: async () => ({ counties: [{ fips: '01001', margin: 0.12 }] }),
    })
  })

  afterEach(() => jest.clearAllMocks())

  it('returns county data', async () => {
    const result = await fetchElectionResults('CA', 2024)
    expect(result.counties).toHaveLength(1)
    expect(result.counties[0].fips).toBe('01001')
  })
})
```

### React Component Tests (React Testing Library)

```typescript
import { render, screen, fireEvent } from '@testing-library/react'
import MarginBadge from '@/components/MarginBadge'

it('renders D+ badge for positive margin', () => {
  render(<MarginBadge margin={0.15} />)
  expect(screen.getByText('D+15.0%')).toBeInTheDocument()
})

it('renders R+ badge for negative margin', () => {
  render(<MarginBadge margin={-0.08} />)
  expect(screen.getByText('R+8.0%')).toBeInTheDocument()
})
```

### Running Tests

```bash
# Jest
npm test                        # watch mode
npm test -- --coverage          # with coverage
npm test -- --testPathPattern=formatters  # specific file

# Vitest
npx vitest run                  # single run
npx vitest run --coverage
```

---

## Coverage Minimums

| Target | Minimum |
|---|---|
| `src/services/` | 80% |
| `src/utils/` | 90% (pure functions — easy to test) |
| `src/components/` | 60% (UI logic; E2E handles the rest) |

---

## What NOT to Test

- Implementation details (test behavior, not internals)
- Third-party library functions
- Trivial getters/setters with no logic
- Anything already covered by E2E tests

---

## When to Load This Skill

- Writing a new service, utility, or pipeline function
- Adding a new API endpoint and writing unit tests for it
- Debugging a fix and writing a regression test to lock in the behavior
- Setting up pytest or Jest for a new project from scratch
