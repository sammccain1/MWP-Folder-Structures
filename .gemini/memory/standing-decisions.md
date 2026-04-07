# Standing Decisions

This file tracks global architectural decisions for the MWP repository that agents should treat as defaults without needing to re-litigate them.

1. **Cross-Validation for Temporal Data**: Any model trained on historical sports seasons MUST use Leave-One-Season-Out (LOSO) cross-validation. Standard K-fold leaks future data into past folds and is explicitly prohibited.
2. **Intermediate Data Format**: Pipelines should write intermediate/processed datasets as `.parquet`, not `.csv`. Parquet preserves data types and is significantly faster, crucial for R <-> Python interop.
3. **Database Migrations**: We use a forward-only migration strategy. Never drop and recreate; always write a discrete migration up/down script.
4. **Agent Workflow Orchestration**: We heavily rely on offloading discrete, atomic tasks to subagents instead of keeping everything in context. Subagents should handle focused research or single-file creation tasks.
5. **No Placeholders in the Frontend**: When adding UI elements in our custom frameworks, ALWAYS implement high-fidelity design standards. Never say "I added a basic box here". Use the `frontend-design` skill styling guidelines by default.
6. **`data/` Directory Structure** _(2026-04-07)_: The Developer template `data/` directory keeps all four subdirectories: `raw/`, `processed/`, `etl-pipelines/`, and `feature-engineering/`. Pipeline scripts (ETL, feature engineering) live adjacent to the data they operate on rather than in `ops/scripts/`, which is reserved for production scheduled jobs and bash automation.
7. **Hook Severity Policy** _(2026-04-07)_: Only `secrets-check.sh` should hard-block the agent (exit 2). All other hooks (`dependency-check`, `test-on-change`, `lint-on-save`) are advisory — they warn via stderr but always exit 0 so they never interrupt unrelated tool calls. Projects that want stricter enforcement must explicitly opt in by changing the hook's `exit 0` to `exit $EXIT_CODE`.
8. **Gemini CLI `settings.json` model field** _(2026-04-07)_: The `model` key must be an object `{"name": "gemini-2.5-pro"}`, not a plain string. Generation parameters (temperature, thinkingBudget) must be expressed via `modelConfigs.customAliases[name].modelConfig.generateContentConfig`, not at the top level.

