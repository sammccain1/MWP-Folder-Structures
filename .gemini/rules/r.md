# R Rules

Stack: R 4.3+, tidyverse, toRvik, testthat, future/furrr

## File & Path Guardrails

- **Always `here::here()`** for file paths — never `setwd()` or absolute paths
- **Never `attach(df)`** — use explicit `df$col` references or tidy evaluation (`{{ }}`)
- `janitor::clean_names()` must be the first transformation after loading any external data
- Source files: `snake_case.R`, one logical unit per file, `source()` from a top-level `run.R`

## Reproducibility

- **Always `set.seed(42)`** at the top of every script AND inside simulation functions that use randomness
- Monte Carlo / bracket sims: set seed inside the function body too — not just at call site
- Record session info in analysis outputs: `sessionInfo()` or `renv::snapshot()`
- Use `renv` for package management — `renv::restore()` must reproduce the environment exactly

## Simulation & Modeling

- **No `for` loops over rows** for data manipulation or simulation mapping
  - Use `purrr::map_dfr()` / `purrr::map2_dfr()` for iteration
  - Use `dplyr::group_modify()` for grouped operations
  - Use `furrr::future_map_dfr()` for parallelized simulation (with `plan(multisession)`)
- Bracket simulations: always return a data frame, never modify state outside the function
- Log simulation parameters alongside results — future you needs to know what `n_sims=1000` meant

## toRvik / Sports Data

- `toRvik` calls are rate-limited — cache results locally: `write_parquet(df, "data/raw/torvik_YYYY.parquet")`
- Never re-fetch data that already exists in `data/raw/` — check before calling
- Season parameter: always explicit (`year = 2026`) — never rely on toRvik defaults
- After fetch: immediately `janitor::clean_names()` then validate expected columns exist

## Tidyverse Idioms

- Assign ggplot objects: `p <- ggplot(...) + ...` then `ggsave("path.png", p, width=10, height=6, dpi=300)`
- Never `png()` / `dev.off()` workflow — use `ggsave()` exclusively
- `case_when()` over nested `ifelse()` for multiple conditions — always
- Pipe to conclusion — avoid intermediate dataframes unless needed for memory debugging
- `dplyr::across()` for column-wise operations — not repeated `mutate()` calls

## Error Handling

- Wrap external data fetches in `tryCatch()`:
  ```r
  tryCatch({
    df <- toRvik::torvik_player_stats(year = 2026)
  }, error = function(e) {
    message("toRvik fetch failed: ", e$message)
    return(NULL)
  })
  ```
- Validate data shape after every load: `stopifnot(nrow(df) > 0, "team" %in% names(df))`
- Use `cli::cli_abort()` instead of `stop()` for user-facing errors — better formatting

## Testing (testthat)

- Test directory: `tests/testthat/test_[module].R`
- Run tests: `testthat::test_dir("tests/testthat")` or `devtools::test()`
- Every simulation function gets a smoke test with a small fixed seed: assert output shape, no NAs in key columns
- Test LOSO CV functions with 3 seasons of dummy data — verify no data leakage between folds

## R ↔ Python Interop

- Intermediate data always `.parquet` — `arrow::write_parquet()` / `arrow::read_parquet()`
- Never use `.RData` or `.rds` for data shared between R and Python
- Column names: `snake_case` throughout — `janitor::clean_names()` normalises on load
- Dates: ISO 8601 strings (`"2026-03-25"`) not R `Date` objects when writing to Parquet for Python
