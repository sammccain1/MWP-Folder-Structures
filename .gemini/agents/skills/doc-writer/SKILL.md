---
name: doc-writer
description: Technical documentation skill for Python, TypeScript/Next.js, and data projects. Load when writing README files, API docs, changelogs, guides, or docstrings. Provides templates, tone guidelines, and formatting patterns for Sam's stack.
---

# Doc Writer Skill

Templates, patterns, and tone guidelines for technical documentation in Sam's stack.

---

## README Template

```markdown
# Project Name

> One-sentence description of what this does and why it exists.

## What It Does

[2–3 sentences. What problem does this solve? Who is it for?]

## Quick Start

```bash
# 1. Clone and install
git clone https://github.com/sammccain1/project-name.git
cd project-name
cp .env.example .env  # Add your keys

# 2. Install dependencies
pip install -r requirements.txt  # or npm install

# 3. Run
uvicorn app.main:app --reload  # or npm run dev
```

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | FastAPI / Python 3.11 |
| Frontend | Next.js 14 / TypeScript |
| Database | PostgreSQL / Supabase |
| Deployment | Vercel |

## Project Structure

```
src/
  components/   # React UI components
  services/     # Business logic and API calls
  utils/        # Shared helpers
docs/           # Documentation
ops/            # Scripts and deployment
Planning/       # Specs and ADRs
```

## Environment Variables

| Variable | Required | Description |
|---|---|---|
| `DATABASE_URL` | ✅ | PostgreSQL connection string |
| `NEXT_PUBLIC_SUPABASE_URL` | ✅ | Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | ✅ | Server-only admin key |

## Development

```bash
npm run dev       # Start dev server
npm run test      # Run tests
npm run lint      # Lint and type-check
```

## License

MIT
```

---

## API Documentation Template

For `docs/api/` files:

```markdown
# API: [Endpoint Group Name]

Base URL: `/api/v1`
Auth: Bearer token required on all routes unless marked public.

---

## GET /endpoint

**Description:** What this endpoint returns.

**Auth:** Required / Public

**Query Parameters:**

| Param | Type | Required | Description |
|---|---|---|---|
| `limit` | integer | No | Max results (default: 20, max: 100) |
| `offset` | integer | No | Pagination offset (default: 0) |

**Response: 200 OK**

```json
{
  "data": [
    { "id": "uuid", "name": "string", "created_at": "ISO8601" }
  ],
  "total": 42
}
```

**Errors:**

| Code | Meaning |
|---|---|
| 401 | Missing or invalid auth token |
| 403 | Insufficient permissions |
| 404 | Resource not found |
| 422 | Validation error — check request body |
```

---

## Changelog Format

For `docs/changelog/` — one file per release:

```markdown
# v1.2.0 — 2026-03-25

## Added
- Political map layer for 2026 election data
- FastAPI `/api/districts` endpoint with GeoJSON response

## Changed
- Upgrade scikit-learn from 1.3 to 1.4
- Switched `bracket_sim.py` to use model predictions only (removed seed-based fallback)

## Fixed
- Null handling in `process_users()` when email field is missing
- CI race condition in `test_auth.py` — added explicit wait for session

## Removed
- Legacy `fetch_data_v1.py` pipeline (replaced by `data_pipeline.py`)
```

---

## Python Docstring Standard

Use Google-style docstrings:

```python
def simulate_bracket(teams: list[Team], iterations: int = 500) -> BracketResult:
    """Simulate a single-elimination bracket using the trained model.

    Args:
        teams: List of Team objects with precomputed features.
        iterations: Number of Monte Carlo simulations to run.

    Returns:
        BracketResult containing win probabilities for each team at each round.

    Raises:
        ValueError: If teams list is empty or has fewer than 2 entries.
        ModelNotFittedError: If the model hasn't been trained yet.

    Example:
        >>> teams = load_teams("data/2026_bracket.json")
        >>> result = simulate_bracket(teams, iterations=1000)
        >>> print(result.champion_probabilities)
    """
```

---

## TypeScript JSDoc Standard

```typescript
/**
 * Fetches district GeoJSON data for a given state.
 *
 * @param stateCode - Two-letter state abbreviation (e.g., "PA")
 * @param year - Election year (e.g., 2026)
 * @returns Promise resolving to GeoJSON FeatureCollection
 * @throws {ApiError} When state code is invalid or data unavailable
 *
 * @example
 * const geo = await fetchDistrictData("PA", 2026)
 * map.addSource("districts", { type: "geojson", data: geo })
 */
export async function fetchDistrictData(
  stateCode: string,
  year: number
): Promise<GeoJSON.FeatureCollection> {
```

---

## Tone & Style Guide

| Rule | Detail |
|---|---|
| Voice | Second person ("You can...") for guides, third person for API docs |
| Length | Short sentences. One idea per sentence. |
| Code blocks | Always include language identifier (` ```python `, ` ```bash `) |
| Headings | Sentence case, not Title Case |
| Placeholders | Use `[REPLACE_ME]` or `your-value-here` — never leave blanks |
| Avoid | Jargon without definition, marketing language, passive voice |
| Always include | A working Quick Start that a new dev can run in under 5 minutes |
