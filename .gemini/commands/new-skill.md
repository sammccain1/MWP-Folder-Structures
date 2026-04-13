---
name: new-skill
description: Scaffolds a new skill directory and template `SKILL.md` to ensure correct formatting and agent awareness.
allowed_tools: ["Bash", "Read", "Write"]
---

# /new-skill

Scaffolds a perfectly structured skill directory and `SKILL.md` to guarantee the agent can process and load it properly.

## Step 1 — Verify Inputs
Confirm the desired skill name (in `kebab-case`).

## Step 2 — Create the Directory
```bash
mkdir -p .gemini/skills/<skill-name>
```

## Step 3 — Generate SKILL.md
Create `.gemini/skills/<skill-name>/SKILL.md` with the following template:

```markdown
---
name: <skill-name>
description: [One clear sentence describing exactly when this skill should be triggered. E.g. "Use this skill when implementing a new React component" or "Use this when debugging AWS permissions"]
---

# <Skill Title>

This skill provides expert-level guidance on [topic]. 

## When to Load
- Use this when...
- Do NOT use this when...

## Core Principles
1. Do X
2. Avoid Y

## Implementation Patterns

### [Pattern Name]
[Description and code snippet]

## Verification
How do we know the skill was executed correctly?
```

## Step 4 — Register the Skill
Update the `.gemini/README.md` and repo root `GEMINI.md` inventories with the new skill name and trigger condition to ensure it gets noticed by agents.
