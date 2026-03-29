---
name: new-project
description: Scaffold a new Developer project from the Folder-Structure-Developer template. Clones the template into a target directory, customises CONTEXT.md files, initialises git, and creates task.md. Use when starting any new ML, pipeline, maps, or web app project.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /new-project

Use this command to **scaffold a new Developer project** from the MWP template. Never work directly inside `Folder-Structure-Developer/` — always clone first.

---

## Required Inputs

Before starting, confirm:

| Input | Example |
|---|---|
| `PROJECT_NAME` | `march-madness-2027` |
| `PROJECT_TYPE` | `ml-model` \| `data-pipeline` \| `web-app` \| `maps` \| `simulation` |
| `TARGET_PATH` | `/Users/sammccain/Projects/march-madness-2027` |
| `DESCRIPTION` | One-line description of what this project does |

---

## Step 1 — Copy the template

```bash
TEMPLATE="/Users/sammccain/ProjectFolderBuilder/MWP-Folder-Structures/Folder-Structure-Developer"
TARGET="<TARGET_PATH>"

cp -r "$TEMPLATE" "$TARGET"
echo "Template copied to: $TARGET"
```

---

## Step 2 — Initialise git

```bash
cd "$TARGET"
git init
git add -A
git commit -m "chore: scaffold from MWP Developer template"
```

---

## Step 3 — Create task.md

Create `$TARGET/task.md` with this starter content:

```markdown
# <PROJECT_NAME>

**Type:** <PROJECT_TYPE>
**Started:** <YYYY-MM-DD>
**Description:** <DESCRIPTION>

## Setup
- [ ] Configure environment (`.env`, `environment.yml` or `requirements.txt`)
- [ ] Add data sources to `data/raw/`
- [ ] Write first test in `src/tests/`

## Core Work
- [ ] [Add project-specific tasks here]

## Verification
- [ ] Tests pass: `pytest src/tests/ -q`
- [ ] No secrets in repo: run `/secrets-check`
- [ ] README updated
```

---

## Step 4 — Update CONTEXT.md files

Edit the following files to replace placeholder text with project-specific content:

- `CONTEXT.md` — project overview, data sources, key decisions
- `src/CONTEXT.md` — source directory layout for this project type
- `docs/CONTEXT.md` — what documentation will be produced
- `Planning/CONTEXT.md` — planning approach for this project type

Use `PROJECT_TYPE` to guide what to keep vs. what to trim.

---

## Step 5 — Project-type specific setup

### `ml-model`
```bash
# Create virtual environment
python -m venv .venv && source .venv/bin/activate
pip install scikit-learn pandas numpy pytest ruff
pip freeze > requirements.txt
```

### `data-pipeline`
```bash
python -m venv .venv && source .venv/bin/activate
pip install pandas requests beautifulsoup4 schedule pytest ruff
pip freeze > requirements.txt
```

### `web-app`
```bash
npm init -y
npm install react react-dom typescript
npm install -D vitest @testing-library/react
```

### `maps`
```bash
# Install spatial dependencies
pip install geopandas folium mapboxgl matplotlib pytest ruff
pip freeze > requirements.txt
```

### `simulation`
```bash
python -m venv .venv && source .venv/bin/activate
pip install numpy pandas scipy scikit-learn pytest ruff
pip freeze > requirements.txt
```

---

## Step 6 — Final commit

```bash
cd "$TARGET"
git add -A
git commit -m "chore: customise template for <PROJECT_NAME>"
```

---

## Verification

Confirm before closing:
- [ ] `git log --oneline` shows 2 commits (scaffold + customise)
- [ ] `task.md` exists at project root
- [ ] No `Folder-Structure-Developer` text remains in CONTEXT.md files
- [ ] `.env` is in `.gitignore`

---

## Notes

- Never commit `.env` files — check with `secrets-check.sh` before first push
- `rules/lessons.md` should be blank at project start — lessons accumulate during the project
- The `data/` directory is git-ignored by default (large files) — add explicit exceptions if small CSVs need tracking
