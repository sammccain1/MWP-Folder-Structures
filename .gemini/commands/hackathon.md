---
name: hackathon
description: Hackathon project kickoff and delivery workflow. Runs when starting any hackathon project. Sets up the full-stack scaffold, establishes the judging rubric, and keeps the team on a winning timeline.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /hackathon

Use this command when **starting a hackathon project** from scratch. It scaffolds the project, aligns the team on the judging criteria, and establishes the 24/48-hour delivery schedule.

---

## Step 1 — Define the Win Criteria

Before any code, answer these:

| Question | Your Answer |
|---|---|
| What is the judging rubric? | (e.g., Innovation 30%, Technical 30%, Design 20%, Demo 20%) |
| Who is the target user? | |
| What is the ONE thing the app does? | |
| What does the MVP look like at the demo? | |

Write the answers in `task.md` at the project root.

---

## Step 2 — Scaffold the Project

Clone the Developer template first:

```bash
cp -r /Users/sammccain/ProjectFolderBuilder/MWP-Folder-Structures/Folder-Structure-Developer ./hackathon-project
cd hackathon-project
git init && git add -A && git commit -m "chore: scaffold from MWP Developer template"
```

Then initialise the full-stack app:

```bash
# Frontend (Next.js App Router)
npx create-next-app@latest src/app --typescript --tailwind --app --src-dir --import-alias "@/*"

# Add UI component library
cd src/app
npx shadcn@latest init
npx shadcn@latest add button card input dialog badge skeleton

# Add motion library
npm install framer-motion lucide-react
```

For the backend, in `src/api/`:
```bash
pip install fastapi uvicorn httpx pydantic python-dotenv
```

---

## Step 3 — Set the 24-Hour Timeline

Adapt based on your hackathon length. For a 24-hour event:

| Time Block | Goal | Owner |
|---|---|---|
| H+0 – H+2 | Scaffold, design tokens, core data model | All |
| H+2 – H+8 | Happy path MVP (data in → data out) | Backend |
| H+2 – H+8 | Hero screen + core UI flow | Frontend |
| H+8 – H+16 | Integration, real data, polish | All |
| H+16 – H+20 | Error states, loading states, mobile | Frontend |
| H+20 – H+22 | Security hardening (run `/pen-test`) | All |
| H+22 – H+24 | Demo rehearsal, slides, README | All |

---

## Step 4 — The Demo Script

Write this before building. The demo drives what you ship.

```markdown
## Demo Script (90 seconds)

1. [0:00–0:15] The hook — state the problem in one sentence
2. [0:15–0:30] Show the persona and their pain (1 screenshot or live data)
3. [0:30–1:00] Live demo — show the core user flow end-to-end
4. [1:00–1:15] The technical wow moment — what's impressive under the hood?
5. [1:15–1:30] Impact / next steps
```

---

## Step 5 — Hackathon-Specific Safety Shortcuts

The following `guardrails.md` rules are **relaxed during hackathons** (speed > perfection):

- ✅ Skip DB migrations — use seed scripts and reset freely
- ✅ Use mock data if the API is slow to build
- ✅ `useEffect` for initial data load is acceptable
- ❌ Never relax: no secrets in code, no `dangerouslySetInnerHTML` with user input

---

## Step 6 — Pre-Demo Checklist

```bash
# 2 hours before demo
bash .gemini/hooks/secrets-check.sh        # no leaked tokens
npm run build                               # production build works
npm run test -- --passWithNoTests          # no crashes
```

- [ ] Demo works on the demo machine (not just yours)
- [ ] Works on a phone (judge will try)
- [ ] Fallback: screenshots or video if live demo breaks
- [ ] README has setup instructions + team names

---

## Notes

- Create a branch called `demo` 2 hours before judging and freeze it — keep pushing to `main` but judge on `demo`
- If you get stuck ≥ 30 mins, cut scope. A finished MVP beats a broken feature every time
- Use the `ui-ux-design` skill for component patterns, the `pen-testing` skill for the security sweep
