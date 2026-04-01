# Standing Decisions

This file tracks global architectural decisions for the MWP repository that agents should treat as defaults without needing to re-litigate them.

1. **Cross-Validation for Temporal Data**: Any model trained on historical sports seasons MUST use Leave-One-Season-Out (LOSO) cross-validation. Standard K-fold leaks future data into past folds and is explicitly prohibited.
2. **Intermediate Data Format**: Pipelines should write intermediate/processed datasets as `.parquet`, not `.csv`. Parquet preserves data types and is significantly faster, crucial for R <-> Python interop.
3. **Database Migrations**: We use a forward-only migration strategy. Never drop and recreate; always write a discrete migration up/down script.
4. **Agent Workflow Orchestration**: We heavily rely on offloading discrete, atomic tasks to subagents instead of keeping everything in context. Subagents should handle focused research or single-file creation tasks.
5. **No Placeholders in the Frontend**: When adding UI elements in our custom frameworks, ALWAYS implement high-fidelity design standards. Never say "I added a basic box here". Use the `frontend-design` skill styling guidelines by default.
