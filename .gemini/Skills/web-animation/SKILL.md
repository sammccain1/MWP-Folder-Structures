---
name: web-animation
description: Remotion video production — programmatic animations and explainer videos. This is the entry-point skill. It triggers when working on any Remotion project. For deeper context, see CONTEXT.md to navigate to the right sub-skill.
---

# Web Animation (Remotion)

Programmatic video production using React + Remotion. Each frame is a React render. Everything is code.

**Source:** [RinDig/Animation-Workflow](https://github.com/RinDig/Animation-Workflow) (MIT)

---

## Quick Start

```bash
npm install remotion @remotion/cli @remotion/bundler react react-dom
npx remotion studio   # preview in browser at localhost:3000
```

---

## The Three Rules

1. **ALL animations use `useCurrentFrame()`** — CSS transitions/animations are FORBIDDEN
2. **Use `spring()` for organic motion** — not `interpolate()` with easing
3. **Always clamp** — `extrapolateLeft: 'clamp', extrapolateRight: 'clamp'`

---

## Workflow

```
Spec → Build → Refine
```

1. **Spec** — write `projects/[name]/spec.md` (scene-by-scene, with timing)
2. **Build** — implement scenes as React components
3. **Refine** — render ProRes, finish in NLE (DaVinci, Premiere, CapCut)

---

## Navigate Sub-Skills

See [`CONTEXT.md`](CONTEXT.md) for the full navigation guide.

| Sub-Skill | When to Load |
|---|---|
| [`spec-writing`](spec-writing/SKILL.md) | Planning a new video |
| [`style-guide`](style-guide/SKILL.md) | Colors, typography, margins |
| [`visual-direction`](visual-direction/SKILL.md) | Entrances, pacing, emphasis vocabulary |
| [`animation-primitives`](animation-primitives/SKILL.md) | Writing animation code |
| [`composition-structure`](composition-structure/SKILL.md) | Multi-scene structure, Series/Sequence |
| [`common-patterns`](common-patterns/SKILL.md) | Stagger, typewriter, counter, crossfade |
| [`rendering`](rendering/SKILL.md) | Final export, codecs, troubleshooting |
