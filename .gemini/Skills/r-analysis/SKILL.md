---
name: r-analysis
description: R analysis patterns for Sam's projects. Load when writing R scripts, tidyverse data wrangling, ggplot2 visualisation, or simulation models. Covers toRvik data export, tidyverse idioms, simulation patterns for bracket models, and R-to-Python interop.
---

# R Analysis Skill

Tidyverse patterns, sports data conventions, and simulation recipes for Sam's R workload. Includes `toRvik` access patterns documented from actual project work.

---

## Project Setup

```r
# Install core packages (run once)
install.packages(c(
  "tidyverse",   # dplyr, tidyr, ggplot2, readr, purrr, stringr
  "toRvik",      # college basketball data
  "lubridate",   # date handling
  "janitor",     # column name cleaning
  "broom",       # tidy model outputs
  "here",        # project-relative paths
))
```

### Directory Convention
```
src/
  r/
    fetch_data.R         # toRvik / API pulls
    clean_data.R         # tidyverse wrangling
    model.R              # simulation or statistical model
    visualise.R          # ggplot2 outputs
data/
  raw/                   # CSV exports from R (never modified)
  processed/             # cleaned parquets / CSVs (for Python interop)
docs/
  figures/               # ggplot2 outputs
```

---

## toRvik Data Export

Based on actual project patterns from Sam's March Madness work:

```r
library(toRvik)
library(tidyverse)
library(here)

# ── Team stats (full season, includes unadjusted) ──
fetch_team_stats <- function(season = 2026) {
  # bart_team_box returns per-game unadjusted stats
  box <- bart_team_box(season = season, type = "all")   # type: "all" | "conf" | "nc"

  # bart_ratings returns KenPom-style adjusted metrics
  ratings <- bart_ratings(season = season)

  # Join on team name — watch for name mismatches
  df <- box %>%
    left_join(ratings, by = c("team", "season")) %>%
    janitor::clean_names()

  return(df)
}

# ── Player stats ──
fetch_player_stats <- function(season = 2026) {
  bart_player_box(season = season) %>%
    janitor::clean_names()
}

# ── Save to CSV for Python interop ──
save_to_csv <- function(df, name, season) {
  path <- here("data", "raw", glue::glue("{season}_{name}.csv"))
  readr::write_csv(df, path)
  message(glue::glue("Saved {nrow(df)} rows → {path}"))
}

# Run
df <- fetch_team_stats(season = 2026)
save_to_csv(df, "team_stats", 2026)
```

> **toRvik known columns to check:** `adj_em`, `adj_o`, `adj_d`, `barthag`, `sos`, `wins`, `losses`. These may differ between `bart_team_box()` and `bart_ratings()` output — join carefully.

---

## Tidyverse Idioms

### Wrangling Template

```r
library(tidyverse)
library(janitor)

clean_team_data <- function(df) {
  df %>%
    # 1. Clean names first (always)
    janitor::clean_names() %>%

    # 2. Drop exact duplicates
    distinct() %>%

    # 3. Coerce types
    mutate(
      season    = as.integer(season),
      seed      = as.integer(seed),
      adj_em    = as.numeric(adj_em),
      win_rate  = wins / (wins + losses),
    ) %>%

    # 4. Rename for consistency with Python pipeline
    rename(
      team_name = team,
      adj_efficiency_margin = adj_em,
    ) %>%

    # 5. Filter
    filter(!is.na(seed), season >= 2010)
}
```

### Common dplyr Patterns

```r
# Group summary
df %>%
  group_by(region, seed) %>%
  summarise(
    mean_adj_em = mean(adj_em, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

# Conditional mutate
df %>%
  mutate(
    tier = case_when(
      seed <= 4  ~ "top",
      seed <= 8  ~ "mid",
      seed <= 12 ~ "low",
      TRUE       ~ "bottom"
    )
  )

# Pivot for ggplot
df %>%
  pivot_longer(cols = c(adj_o, adj_d), names_to = "metric", values_to = "value")
```

---

## Simulation Model Pattern

Used for bracket simulation and sports outcome modelling:

```r
library(tidyverse)

#' Simulate a single tournament bracket
#' @param teams DataFrame with columns: team, seed, adj_em, barthag
#' @param n_sims Number of Monte Carlo iterations
simulate_bracket <- function(teams, n_sims = 1000) {
  results <- map_dfr(seq_len(n_sims), function(sim_id) {
    remaining <- teams
    round_num <- 1

    while (nrow(remaining) > 1) {
      # Pair teams for matchups
      matchups <- remaining %>%
        mutate(matchup_id = ceiling(row_number() / 2))

      winners <- matchups %>%
        group_by(matchup_id) %>%
        group_modify(~ simulate_game(.x)) %>%
        ungroup()

      remaining <- winners
      round_num <- round_num + 1
    }

    remaining %>% mutate(sim_id = sim_id)
  })

  return(results)
}

#' Simulate a single game using win probability from barthag
simulate_game <- function(matchup) {
  stopifnot(nrow(matchup) == 2)

  p1 <- matchup$barthag[1] / (matchup$barthag[1] + matchup$barthag[2])
  winner_idx <- sample(1:2, 1, prob = c(p1, 1 - p1))

  matchup[winner_idx, ]
}

# Run
set.seed(42)
championship_probs <- simulate_bracket(teams_2026, n_sims = 10000) %>%
  count(team, sort = TRUE) %>%
  mutate(win_prob = n / 10000)
```

---

## R ↔ Python Interop

```r
# Export from R: use CSV (universal) or Arrow/parquet
readr::write_csv(df, "data/processed/team_stats_2026.csv")
arrow::write_parquet(df, "data/processed/team_stats_2026.parquet")
```

```python
# Import in Python
import pandas as pd
df = pd.read_parquet("data/processed/team_stats_2026.parquet")
```

**Rules:**
- Prefer `.parquet` for large files (retains dtypes, no encoding issues)
- Use `.csv` only for small reference tables or when Python side uses `pd.read_csv`
- Never export `.RData` or `.rds` for Python interop — use open formats

---

## Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| Joining on team name without normalisation | Use `tolower(str_trim(team))` before joins |
| `attach(df)` or `<<-` | Use explicit `df$col` and `<-` in local scope |
| `for` loop over rows | Use `purrr::map_dfr()` or `dplyr::group_modify()` |
| Saving figures with `png()` / `dev.off()` | Use `ggplot2::ggsave()` — cleaner, consistent DPI |
| Hard-coded file paths | Use `here::here()` for all paths |
| `set.seed()` only at top level | Set seed inside simulation function for reproducibility |
