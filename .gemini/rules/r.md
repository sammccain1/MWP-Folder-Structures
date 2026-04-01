# R Rules

Stack: R, tidyverse, toRvik

## General Guardrails

- **Always use `here::here()`** for file paths — never use `setwd()`. This ensures paths resolve correctly regardless of the working directory
- **Never `attach(df)`** — use explicit `df$col` references or tidy evaluation to avoid namespace collisions and hidden state
- `janitor::clean_names()` must be the first step after loading any external data

## Simulation & Modeling

- **Always `set.seed(42)`** inside simulation functions (in addition to the top level) to guarantee exact reproducibility of Monte Carlo steps
- Never use `for` loops over rows for data manipulation or simulation mapping. Use `purrr::map_dfr()`, `lapply()`, or `dplyr::group_modify()`

## Tidyverse Idioms

- Assign ggplot objects to a variable (e.g., `p <- ggplot(...)`) and use `ggsave()`. Do not use `png()` / `dev.off()` workflows
- Use `case_when()` instead of nested `ifelse()` statements for multiple conditions
- Avoid keeping intermediate dataframes unless necessary for memory debugging. Pipe operations `%>%` to their conclusion
