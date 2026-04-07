# Bash / Shell Scripting Rules

Guardrails for all shell scripts in `ops/scripts/` and `.gemini/hooks/`.

---

## Safety Header (Required on Every Script)

```bash
#!/usr/bin/env bash
set -euo pipefail
```

| Flag | Effect |
|---|---|
| `-e` | Exit immediately on any non-zero return code |
| `-u` | Treat unset variables as errors |
| `-o pipefail` | Propagate failures through pipes (not just the last command) |

**Exception:** If a command is allowed to fail, suffix it with `|| true` — never disable the flags.

---

## Variable Quoting

```bash
# ✅ Always quote variables — prevents word splitting and glob expansion
echo "$my_var"
cp "$source_file" "$dest_dir/"
for file in "$@"; do echo "$file"; done

# ❌ Never unquoted in a context that can expand
cp $my_var $dest   # breaks on filenames with spaces
```

---

## Arrays

```bash
# ✅ Use arrays for lists of arguments — never concatenate into a string
files=("file one.txt" "file two.txt")
process "${files[@]}"

# ❌ Never do this
files="file one.txt file two.txt"
process $files   # splits on spaces — breaks filenames with spaces
```

---

## Functions

```bash
# ✅ Declare local variables inside functions
my_function() {
  local input="$1"
  local result
  result=$(do_something "$input")
  echo "$result"
}

# ❌ Never use global variable names inside functions without local
```

---

## Command Substitution

```bash
# ✅ Use $() — readable + nestable
result=$(git rev-parse --abbrev-ref HEAD)

# ❌ Avoid backticks — deprecated and harder to nest
result=`git rev-parse --abbrev-ref HEAD`
```

---

## Error Handling

```bash
# ✅ Guard commands that may legitimately return non-zero
CHANGED=$(git diff --name-only 2>/dev/null || true)

# ✅ Check before using
if [[ -z "$CHANGED" ]]; then
  echo "Nothing changed" >&2
  exit 0
fi

# ✅ Trap for cleanup on exit
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT
```

---

## stdin / stdout / stderr Rules (Hook Scripts)

```bash
# ✅ All human-readable logging goes to stderr
echo "[my-hook] Processing..." >&2

# ✅ Only JSON goes to stdout (Gemini CLI hook protocol)
echo '{"decision": "deny", "reason": "Secret found"}' # stdout = parsed by CLI

# ❌ Never mix logging with JSON output on stdout
echo "Processing..."   # ← breaks Gemini CLI JSON parser if hook outputs JSON
```

---

## Production-Write Scripts

- Any script that writes or deletes production data **MUST** require an explicit `--confirm` flag
- Print a dry-run summary first, then require `--confirm` to proceed

```bash
DRY_RUN=true
for arg in "$@"; do
  [[ "$arg" == "--confirm" ]] && DRY_RUN=false
done

if $DRY_RUN; then
  echo "DRY RUN: would delete 1,234 rows. Pass --confirm to execute." >&2
  exit 0
fi
# ... destructive operation
```

---

## Portability (macOS vs Linux)

| Issue | macOS (BSD) | Linux (GNU) | Fix |
|---|---|---|---|
| `sed -i` | Requires empty string: `sed -i ''` | Works without: `sed -i` | Use `perl -i -pe` for portability |
| `date` | No `--date` flag | Has `--date` flag | Use `python3 -c "import datetime..."` |
| `readlink -f` | Not available | Available | Use `$(cd ... && pwd)` pattern |
| `grep -P` | Not available | Available | Use `grep -E` (ERE) for portability |

---

## Naming Conventions

```
kebab-case.sh   for all shell scripts
snake_case.sh   acceptable for utility functions
SCREAMING_CASE  for constants: readonly MAX_RETRIES=3
```

---

## Checklist Before Committing a Script

```
[x] Has #!/usr/bin/env bash shebang
[x] Has set -euo pipefail
[x] All variables quoted
[x] Uses local inside functions
[x] Stderr/stdout separated correctly
[x] --confirm flag on any destructive operation
[x] Passes shellcheck (run: shellcheck script.sh)
```
