---
name: performance
description: Web and Python performance optimization — Next.js bundle analysis, Core Web Vitals, ISR vs SSR decisions, Python profiling with cProfile and memory_profiler, Pandas vectorization fixes, and SQL query optimization. Load when diagnosing slow pages, large bundles, or slow data pipelines.
---

# Performance Skill

Patterns for diagnosing and fixing performance bottlenecks across the full stack.

---

## Next.js — Bundle Analysis

```bash
# Install bundle analyzer
npm install -D @next/bundle-analyzer

# next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
})
module.exports = withBundleAnalyzer({})

# Run analysis
ANALYZE=true npm run build
# Opens treemap in browser — look for: large vendor chunks, duplicate deps, unused imports
```

**Key targets:**
- Total JS sent to client: aim for **<200KB gzipped** for initial page
- No duplicate libraries (e.g., two versions of lodash)
- Heavy libs (moment.js, lodash) should be replaced or tree-shaken

---

## Next.js — Image Optimization

```tsx
// ✅ Always use next/image — automatic WebP, lazy loading, size optimization
import Image from 'next/image'

<Image
  src="/map-screenshot.png"
  alt="County election map"
  width={1200}
  height={800}
  priority={true}    // set on above-the-fold images only
  placeholder="blur" // use with blurDataURL for smooth load
/>

// ❌ Never use bare <img> for user-facing content in Next.js
<img src="/map-screenshot.png" />
```

---

## Next.js — Rendering Strategy

| Strategy | When to Use |
|---|---|
| **Static (SSG)** | Content doesn't change per user or per request (e.g., blog, docs) |
| **ISR** | Content changes occasionally — election results, standings (revalidate: 60) |
| **SSR** | Content is user-specific or real-time (auth pages, live scores) |
| **Client fetch** | Small, interactive, low-priority data (charts that update on click) |

```typescript
// ISR — revalidate every 60 seconds
export const revalidate = 60

// SSR — opt into dynamic rendering
export const dynamic = 'force-dynamic'
```

---

## Core Web Vitals Targets

| Metric | Target | How to Fix |
|---|---|---|
| **LCP** (Largest Contentful Paint) | < 2.5s | Use `priority` on hero image; reduce server response time |
| **FID/INP** (Interaction) | < 200ms | Reduce JS bundle; defer non-critical scripts |
| **CLS** (Layout Shift) | < 0.1 | Set explicit width/height on images; avoid inserting content above fold |

```bash
# Measure locally
npx lighthouse http://localhost:3000 --output=html --output-path=./lighthouse-report.html
```

---

## Python — cProfile

```python
import cProfile
import pstats

# Profile a function
with cProfile.Profile() as pr:
    result = my_slow_function(data)

stats = pstats.Stats(pr)
stats.sort_stats("cumulative")
stats.print_stats(20)  # top 20 slowest functions

# Or from CLI
python -m cProfile -s cumulative my_script.py | head -30
```

**Reading the output:**
- `tottime` — time in this function excluding sub-calls (where the actual work is)
- `cumtime` — total time including sub-calls (shows the call path)

---

## Python — Memory Profiling

```bash
pip install memory-profiler
```

```python
from memory_profiler import profile

@profile
def load_and_process():
    df = pd.read_csv("data/raw/big_file.csv")   # line-by-line memory shown
    df_clean = df.dropna()
    return df_clean
```

**Common memory fixes:**
- Use `pd.read_csv(..., chunksize=N)` for large files
- Cast high-cardinality columns to `category` dtype
- Use Parquet instead of CSV (5-10x smaller in memory)
- Delete intermediates: `del df_raw` + `gc.collect()`

---

## SQL Query Optimization

```sql
-- ✅ Use EXPLAIN ANALYZE to diagnose slow queries
EXPLAIN ANALYZE
SELECT county_name, dem_votes / total_votes AS margin
FROM election_results
WHERE state = 'CA' AND year = 2024;

-- ✅ Index columns used in WHERE, JOIN, and ORDER BY
CREATE INDEX idx_election_state_year ON election_results(state, year);

-- ❌ Avoid SELECT * — fetches unneeded columns and breaks column-level indexes
SELECT * FROM election_results WHERE state = 'CA';

-- ✅ Use LIMIT during development to avoid full table scans
SELECT * FROM election_results WHERE state = 'CA' LIMIT 100;
```

---

## When to Load This Skill

- Next.js page is slow or Lighthouse score < 80
- Bundle size is large or growing unexpectedly
- Python ETL pipeline or feature engineering script takes too long
- Pandas operations are timing out on large DataFrames
- A SQL query is running for >1 second and needs optimization
