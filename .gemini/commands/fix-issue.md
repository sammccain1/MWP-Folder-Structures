---
name: fix-issue
description: Alias for /debug. Redirects to the canonical autonomous bug fix workflow.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /fix-issue → /debug

This command is an alias. Use `/debug` instead — it is the canonical autonomous bug fix workflow and includes the debugger skill.

```
/debug
```

The `/debug` command:
- Loads `.gemini/Skills/debugger/SKILL.md` automatically
- Follows the 6-step reproduce → isolate → hypothesize → fix → verify → commit protocol
- Covers Python, TypeScript, SQL, R, and data pipeline failures
