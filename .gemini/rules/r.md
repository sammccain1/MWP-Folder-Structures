# R Rules

Guardrails for R 4.3+, tidyverse, {targets}, and {pointblank} workflows.

---

## Core Philosophy

- **Functional Pipelines:** Pipe logic through clear, discrete transformations.
- **Reproducibility:** Every script must be runnable from a clean session.
- **Strict Typing/Validation:** Use parquet for interop and validate data shapes at every boundary.

---

## Project Structure & Paths

```r
# ✅ ALWAYS use here::here()
filepath <- here::here("data", "raw", "results.parquet")

# ❌ NEVER use setwd() or absolute paths
setwd("/Users/sam/Desktop/Project")
source("C:/Users/sam/Project/script.R")
```

---

## Data Transformation (tidyverse)

### Clean Names First
```r
df <- read_parquet(here::here("data", "raw", "results.parquet")) |>
  janitor::clean_names() # 01_FIPS -> fips
```

### Functional Iteration (purrr)
```r
# ✅ Use map family over for loops
sim_results <- purrr::map(1:1000, ~run_bracket_sim(seed = .x)) |>
  purrr::list_rbind()

# ❌ Avoid for loops for data frame construction
for(i in 1:1000) { ... }
```

### Pivot & Join
- Always check row counts after a join.
- Use `inner_join` only when you are sure of 1:1 or N:1 mappings.

---

## Pipeline Orchestration ({targets})

- Use `{targets}` for any non-trivial analysis to manage dependency graphs.
- Never run long computations in an interactive session; define a target.

```r
# _targets.R
library(targets)
list(
  tar_target(raw_file, "data/raw/data.csv", format = "file"),
  tar_target(data, read_csv(raw_file)),
  tar_target(model, fit_model(data))
)
```

---

## Data Validation ({pointblank})

- Validate data at the start and end of every pipeline.

```r
library(pointblank)

agent <- create_agent(tbl = df) |>
  col_is_character(columns = vars(fips)) |>
  col_val_between(columns = vars(margin), left = -1, right = 1) |>
  interrogate()

if (!all_passed(agent)) stop("Data validation failed!")
```

---

## Visualization (ggplot2)

```r
# ✅ Build layers logically
p <- ggplot(df, aes(x = margin, y = total_votes)) +
  geom_point(alpha = 0.5, color = "steelblue") +
  theme_minimal(base_size = 14) +
  labs(
    title = "Vote Margin vs Volume",
    x = "Dem Margin",
    y = "Total Votes"
  )

# ✅ Save with ggsave
ggsave(here::here("docs", "plots", "margin_plot.png"), p, width = 10, height = 7)
```

**Rule:** Use `labs()` for all annotations. Never use `theme_set()` in shared scripts; define themes locally or in a central `style.R`.

---

## Simulation Best Practices

- **Discrete Seeds:** Set seed inside the simulation function for perfect reproducibility.
- **Parallelization:** Use `furrr` for heavy simulations.

```r
library(furrr)
plan(multisession, workers = parallel::detectCores() - 1)

results <- future_map(seeds, run_sim, .options = fedora_options(seed = TRUE))
```

---

## Rules Summary

| Rule | Rationale |
|---|---|
| here::here() | Cross-platform, project-relative path consistency |
| No for-loops | purrr is faster and more expressive for simulations |
| targets for pipelines | Prevents redundant computation; clear lineage |
| pointblank validation | Early detection of data corruption / upstream changes |
| Parquet for Export | Preserves data types (especially dates/factors) for Python interop |
| Explicit Seed | 1:1 reproducibility for bracket sims and ML models |
