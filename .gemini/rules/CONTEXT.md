# rules/ — Agent Runtime State

You are in the **rules directory** at the MWP repository root. This directory holds append-only runtime files written by hooks and agents during live sessions.

## Files

| File | Written By | Purpose |
|---|---|---|
| `lessons.md` | Agent (after user corrections) | Self-improvement log — read at every session start |
| `audit.log` | Hooks (automatically) | Append-only record of every hook execution |

## Rules

- **Never edit `audit.log` by hand** — it is machine-written by `post-tool.sh`, `pre-commit.sh`, and other hooks
- **`lessons.md` is written by the agent**, not by hooks — one entry per user correction, in the format defined in the file
- Both files are gitignored in project workspaces (to keep audit trails local) but committed here in the MWP meta-repo for reference
- If `audit.log` grows large, archive it: `mv rules/audit.log rules/audit-YYYY-MM.log && touch rules/audit.log`

## Distinction from `.gemini/rules/`

`.gemini/rules/` contains **static guardrail files** — hard rules for how the agent should behave (api.md, database.md, etc.). Those are read-only from the agent's perspective.

`rules/` (this directory) contains **dynamic runtime state** — files that grow and change during active sessions.
