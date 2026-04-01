# Web Animation — Skill Navigation Guide

This folder is a structured skill library for **Remotion** programmatic video production. It breaks the workflow into 7 focused sub-skills. Load only what you need for the current task — don't load them all at once.

---

## Workflow: Spec → Build → Refine

```
1. SPEC    — Plan the video scene-by-scene before writing code
2. BUILD   — Write React components; Remotion renders them frame-by-frame
3. REFINE  — Export and finish in a video editor (DaVinci, Premiere, CapCut)
```

---

## Sub-Skill Map

| Folder | SKILL.md | Load When |
|---|---|---|
| `spec-writing/` | [SKILL.md](spec-writing/SKILL.md) | Starting a new video — before any code. Write the spec first. |
| `style-guide/` | [SKILL.md](style-guide/SKILL.md) | Making color, typography, or margin decisions. |
| `visual-direction/` | [SKILL.md](visual-direction/SKILL.md) | Translating creative intent into visual terms (entrances, pacing, emphasis). |
| `animation-primitives/` | [SKILL.md](animation-primitives/SKILL.md) | Writing animation code — `useCurrentFrame()`, `spring()`, `interpolate()`. |
| `composition-structure/` | [SKILL.md](composition-structure/SKILL.md) | Structuring a multi-scene composition — `Series`, `Sequence`, scene template. |
| `common-patterns/` | [SKILL.md](common-patterns/SKILL.md) | Implementing a specific effect: stagger, typewriter, counter, crossfade, etc. |
| `rendering/` | [SKILL.md](rendering/SKILL.md) | Exporting the final video — codec selection, render commands, troubleshooting. |

---

## Decision Tree: Which Skill to Load?

```
Starting a brand new video project?
  → spec-writing  (write before touching code)

Deciding what the video should look like?
  → visual-direction  (entrances, emphasis, pacing vocabulary)
  → style-guide       (colors, fonts, safe margins)

Writing or debugging animation code?
  → animation-primitives   (frame model, spring, interpolate)
  → common-patterns        (specific effects: stagger, counter, etc.)

Structuring scenes and compositions?
  → composition-structure  (Series vs Sequence, scene template)

Rendering the final output?
  → rendering  (ProRes vs H.264, render commands, troubleshooting)
```

---

## Typical Workflow Sequence

```
Phase 1 — Plan
  1. Load spec-writing → write projects/[name]/spec.md
  2. Load style-guide  → decide color palette + typography
  3. Load visual-direction → annotate spec with entrance/pacing terms

Phase 2 — Build
  4. Load composition-structure → set up Root.tsx + scene shells
  5. Load animation-primitives  → implement spring/interpolate animations
  6. Load common-patterns       → drop in specific effects (stagger, typewriter)

Phase 3 — Refine
  7. Load rendering → run final render, export to NLE
```

---

## Common Task → Skill Lookup

| Task | Load |
|---|---|
| "Write a spec for a 2-minute explainer" | `spec-writing` |
| "What color should I use for this error state?" | `style-guide` |
| "How do I make text slide in from below?" | `visual-direction` → `animation-primitives` |
| "Build a staggered list entrance" | `common-patterns` |
| "My animation goes out of range" | `animation-primitives` (clamp) |
| "Scene plays wrong in Series" | `composition-structure` |
| "Export for DaVinci Resolve" | `rendering` (ProRes) |
| "Export for YouTube upload" | `rendering` (H.264 CRF 18) |
| "Spring feels too fast/slow" | `animation-primitives` (spring configs table) |
| "What's the minimum font size?" | `style-guide` |

---

## Source

Skills adapted from [RinDig/Animation-Workflow](https://github.com/RinDig/Animation-Workflow) (MIT License).
