# Contributing to MWP

MWP is an agent protocol — every file an agent reads shapes how it behaves. Quality and precision matter more than quantity. Before adding anything, ask: does this make the agent meaningfully better at a specific task, or is it noise that dilutes the signal?

---

## Adding a Skill

Skills live in `.gemini/Skills/[skill-name]/SKILL.md`.

### Requirements

Every skill file must have:

1. **YAML frontmatter** — name, description, trigger condition
2. **Specific trigger** in the description — when exactly should this load?
3. **Stack-specific content** — Sam's actual stack, not generic advice
4. **Code examples** — concrete patterns with ✅ correct and ❌ anti-pattern
5. **No overlap** with existing skills — check before writing

### Frontmatter format

```yaml
---
name: skill-name
description: One sentence. Load when [specific trigger condition]. Covers [what it provides].
---
```

The description is what the agent reads to decide whether to load the skill. It must be specific enough to trigger on the right tasks and not on the wrong ones.

### File naming

```
.gemini/Skills/skill-name/SKILL.md   ← all lowercase, kebab-case
```

### After adding a skill

1. Add a row to the skills inventory table in `GEMINI.md`
2. Add a row to the folder structure table in `Folder-Structure-Developer/CLAUDE.md`
3. Add a row to the skills table in `Folder-Structure-Consultant/CLAUDE.md` if relevant to consulting work
4. Add an entry to `CHANGELOG.md`

### Sub-skill libraries

If a skill is complex enough to need sub-skills (like `web-animation`), create:

```
.gemini/Skills/skill-name/
  SKILL.md          ← entry point, references sub-skills
  CONTEXT.md        ← navigation guide: when to load which sub-skill
  sub-skill-one/SKILL.md
  sub-skill-two/SKILL.md
```

---

## Adding a Command

Commands live in `.gemini/commands/[command-name].md`.

### Requirements

Every command file must have:

1. **YAML frontmatter** — name, description, allowed_tools
2. **Numbered steps** — specific, executable, in order
3. **Bash code blocks** for any shell operations
4. **No hardcoded paths** — use `git rev-parse --show-toplevel` or relative paths
5. **Integration** — reference relevant skills, hooks, and other commands where appropriate

### Frontmatter format

```yaml
---
name: command-name
description: One sentence. What this does and when to use it.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---
```

### File naming

```
.gemini/commands/command-name.md   ← all lowercase, kebab-case
```

### After adding a command

1. Add a row to the commands table in `GEMINI.md`
2. Add it to the command reference table in the relevant workspace CLAUDE.md
3. Wire it into related commands where appropriate (e.g. `/review` is referenced by `/hackathon`)
4. Add an entry to `CHANGELOG.md`

---

## Adding a Hook

Hooks live in `.gemini/hooks/[hook-name].sh` and must be wired in `.gemini/settings.json`.

### Requirements

Every hook script must:

1. **`set -euo pipefail`** at the top
2. **All logging to stderr** — stdout is reserved for JSON output that Gemini CLI parses
3. **Fail silently** when tools aren't installed — never block unrelated work
4. **Append to `rules/audit.log`** — every hook execution gets a log line
5. **Exit 0** on skip/pass, **exit 1** on soft failure, **exit 2** on hard block (secrets-check only)
6. **Be idempotent** — safe to run multiple times in a session

### settings.json wiring

Add to the appropriate lifecycle event:

```json
{
  "hooks": {
    "BeforeTool": [
      {
        "matcher": "tool_name_pattern",
        "hooks": [{
          "name": "hook-name",
          "type": "command",
          "command": ".gemini/hooks/hook-name.sh",
          "description": "One sentence.",
          "timeout": 15000
        }]
      }
    ]
  }
}
```

Available lifecycle events: `SessionStart`, `BeforeTool`, `AfterTool`.

### After adding a hook

1. `chmod +x .gemini/hooks/hook-name.sh`
2. Add a row to the hooks table in `GEMINI.md`
3. Add an entry to `CHANGELOG.md`

---

## Adding a Rule

Rules live in `.gemini/rules/[domain].md`.

### Requirements

Every rule file must:

1. **State the stack** at the top — which languages/frameworks these rules cover
2. **Use "Never" and "Always"** for hard rules — imperative mood, no ambiguity
3. **Include code examples** for non-obvious rules — show the wrong pattern and the right pattern
4. **Not duplicate** what's already in a skill file — rules are hard guardrails, skills are deep reference

### When to add a rule vs. a skill

- **Rule** — a hard constraint that applies on every task, regardless of context. "Never use `.inplace=True`". "Always parameterize SQL."
- **Skill** — deep reference loaded only when doing a specific type of work. The full Playwright POM template. The LOSO CV implementation pattern.

### After adding a rule

1. Add it to the rules list in `GEMINI.md` under "Agent Configuration"
2. Add an entry to `CHANGELOG.md`

---

## Commit Conventions

```
feat: add [skill/command/hook/rule name]
fix: [what was broken and how it's fixed]
chore: [maintenance, renaming, cleanup]
docs: [README, CONTRIBUTING, CONTEXT.md changes]
refactor: [restructuring without behaviour change]
```

One logical change per commit. No "misc fixes" commits.

---

## What Not to Add

- Generic best practices that apply to all projects everywhere — MWP is opinionated for Sam's stack
- Skills that duplicate existing skills — check the inventory first
- Hooks that run on every tool call unless truly necessary — each hook adds latency
- Rules that are already covered by a skill — keep rules for hard limits only
- Hardcoded paths to local machines in any file
