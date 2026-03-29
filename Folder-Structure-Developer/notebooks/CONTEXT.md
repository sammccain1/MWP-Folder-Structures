# notebooks/ — Exploratory Analysis & Prototyping

You are in the **notebooks directory**. This is where exploratory, research, and prototype work lives before it graduates to `src/`.

## What Belongs Here

- Exploratory data analysis (EDA) notebooks
- Model prototyping and experimentation
- One-off data investigations
- Visualizations used to inform decisions (not for production output)
- R Markdown documents for statistical analysis

## What Does NOT Belong Here

- Production pipeline logic — that goes in `src/` or `ops/scripts/`
- Notebooks that are called by automated jobs — extract to `.py` scripts first
- Notebooks with hardcoded file paths to your local machine

## Naming Convention

```
kebab-case.ipynb
kebab-case.Rmd

Examples:
  eda-election-turnout.ipynb
  mm-model-feature-selection.ipynb
  bracket-sim-v2.ipynb
  political-map-exploration.Rmd
```

## Rules

- Clear all outputs before committing — `Kernel → Restart & Clear Output` (prevents large diffs and accidental data leaks)
- Use relative paths only — `../../data/raw/file.csv` not `/Users/sam/...`
- When a notebook produces a useful function or class, extract it to `src/utils/` or `src/services/`
- Notebooks are exploratory by nature — document assumptions and dead ends, not just results
- If a notebook becomes the basis for a production pipeline, create an ADR in `Planning/decisions/` documenting the graduation path
