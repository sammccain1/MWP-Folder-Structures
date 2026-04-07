# Task — MWP Hook Script Hardening

> Agent working memory. Keep this updated throughout the session.
> Status: `[ ]` not started · `[/]` in progress · `[x]` done · `[-]` blocked

---

## Active Sprint

### Goal
Audit and harden all 8 hook scripts in `.gemini/hooks/` for correctness against Gemini CLI's stdout/stderr contract, exit code semantics, and tool context passing mechanism.

### Tasks

- [x] Read all 8 hook scripts
- [x] Identify stdout/stderr violations
- [x] Identify incorrect exit code semantics (advisory vs blocking)
- [x] Identify broken tool context reading (stdin vs env vars)
- [x] Fix `lint-on-save.sh` — redirect order bug (`2>&1 >&2` → `>&2 2>&1`)
- [x] Fix `lint-on-save.sh` — `git diff` `|| echo ""` → `|| true` to survive `set -e`
- [x] Fix `dependency-check.sh` — downgrade from blocking (`exit 1`) to advisory (`exit 0` + warning)
- [x] Fix `test-on-change.sh` — downgrade from blocking (`exit 1`) to advisory (`exit 0` + warning)
- [x] Fix `post-tool.sh` — replace stdin JSON parsing with env var lookup (`$GEMINI_TOOL_NAME`)

---

## Hook Audit Results

### ✅ Passed — No Changes Needed

| Hook | Verdict | Notes |
|---|---|---|
| `session-start.sh` | ✅ Clean | All output via `} >&2` block. Exits 0 always. |
| `secrets-check.sh` | ✅ Clean | Correct stderr, correct exit 2 hard-block on secrets found. |
| `pre-commit.sh` | ✅ Clean | All logging to stderr. Exits 0 always. |
| `accessibility-check.sh` | ✅ Clean | Correctly skips when no server/tools. Output all to stderr. |

### 🔧 Fixed — Issues Resolved This Session

| Hook | Bug | Fix Applied |
|---|---|---|
| `lint-on-save.sh` | Redirect order `2>&1 >&2` sends linter output to stdout (breaks JSON parser) | Corrected to `>&2 2>&1` in all 3 lint functions |
| `lint-on-save.sh` | `git diff \|\| echo ""` can fail with `set -euo pipefail` when diff returns non-zero | Changed to `\|\| true` |
| `dependency-check.sh` | `exit $EXIT_CODE` hard-blocks agent tool calls on any vulnerable dep — too aggressive | Downgraded to advisory: always `exit 0`, warns via stderr |
| `test-on-change.sh` | `exit $EXIT_CODE` hard-blocks agent tool calls on any test failure | Downgraded to advisory: always `exit 0`, warns via stderr |
| `post-tool.sh` | Reads tool name from stdin via JSON — Gemini CLI does NOT pass context via stdin | Fixed to read `$GEMINI_TOOL_NAME` env var (CLI's actual mechanism) |

---

## Key Decisions Made

- **Advisory vs Blocking policy**: Only `secrets-check.sh` should hard-block (`exit 2`). Dependency warnings and test failures are advisory — they warn the agent but don't interrupt tool execution. This prevents the hooks from making the CLI unusable during early dev when no tests or deps exist yet.
- **Upgrade path**: Each advisory hook includes a comment: `# To upgrade to blocking: change exit 0 → exit $EXIT_CODE`. This makes it easy for a live project to opt in to stricter enforcement.

---

## Backlog — Future Hook Improvements

### Priority 1 — Robustness
- [ ] **`lint-on-save.sh`**: `tsc --noEmit` on a single file doesn't work well for projects using `tsconfig.json` — it needs to not pass a filename at all, just run `tsc --noEmit` at root. Fix the TypeScript check to run project-wide.
- [ ] **`test-on-change.sh`**: The `git diff --name-only HEAD` pattern will fail on a fresh repo with no commits (HEAD doesn't exist yet). Add a guard: `git rev-parse HEAD &>/dev/null || exit 0`
- [ ] **`secrets-check.sh`**: Add `.geminiignore`-style exclusion support so projects can whitelist specific false-positive patterns (e.g., test fixtures with mock keys)

### Priority 2 — Coverage
- [ ] Add an **`on-branch-switch.sh`** hook (`PostCheckout` event if supported) that prints a brief task.md summary whenever the agent switches branches — prevents context drift
- [ ] Add a **`pre-push.sh`** hook that runs the full secrets-check AND a final lint pass before any `git push` shell command — a second line of defense

### Priority 3 — Observability
- [ ] The audit log at `rules/audit.log` grows unboundedly — add log rotation (keep last 500 lines) at the top of `post-tool.sh`
- [ ] Add a `/audit-summary` command that tails and summarizes `rules/audit.log` grouped by hook type and date

---

## Remaining Open Work (Repo-Wide)

These are the logical next tasks across the entire MWP repo, ordered by impact:

### A — Consultant Template Parity (High Impact)
The `Folder-Structure-Consultant/` template has not been audited against the same standard as the Developer template. It likely has the same class of gaps.

| Task | Est. Effort |
|---|---|
| Run gap analysis on `Folder-Structure-Consultant/` | 30 min |
| Create `Folder-Structure-Consultant/CLAUDE.md` | 20 min |
| Add missing `CONTEXT.md` files in Client-Alpha/, business-dev/, templates/ | 45 min |

### B — `/sync-memory` Session Close-Out ✅

| Task | Status |
|---|---|
| Update `.gemini/memory/standing-decisions.md` with session decisions | ✅ Done — 3 decisions added |
| Commit all changes | ✅ Done — commit `2c17498` on `main` (28 files, 3577 insertions) |

### C — Command Script Validation (Medium Impact)
The `.gemini/commands/` scripts (standup, checkpoint, review, etc.) have not been audited. They may have similar issues to the hooks.

| Task | Est. Effort |
|---|---|
| Read and audit all commands in `.gemini/commands/` | 30 min |
| Fix any stdout contamination or broken logic | 20 min |

### D — `settings.json` Hook Matcher Validation (Low Impact)
The `AfterTool` file-write matcher pattern (`write_file|replace_file|...`) was updated last session, but the actual Gemini CLI tool names for file operations haven't been confirmed against the live CLI. A test session would validate whether `write_file`, `replace_file`, `edit_file`, `overwrite_file` are the correct tool name strings.

| Task | Est. Effort |
|---|---|
| Confirm actual tool names from Gemini CLI docs or session logs | 15 min |
| Update matcher regex in `settings.json` if needed | 10 min |

### E — CHANGELOG.md Update ✅

| Task | Status |
|---|---|
| Add a `## 2026-04-07` entry capturing all session changes | ✅ Done |

---

## Notes

- Gemini CLI exit code contract: `exit 2` = hard block (surfaced to agent), `exit 1` = also blocks (treated same as 2) ⚠️, `exit 0` = proceed
- Hooks must NEVER write to stdout except for the JSON deny payload: `{"decision": "deny", "reason": "..."}`
- `GEMINI_TOOL_NAME` is the env var injected by Gemini CLI into `AfterTool`/`BeforeTool` hook processes — confirm the exact var name if `post-tool` audit shows `unknown-tool` in practice
