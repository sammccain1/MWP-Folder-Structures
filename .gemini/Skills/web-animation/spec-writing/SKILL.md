---
name: web-animation/spec-writing
description: Remotion video spec writing. Load when planning a new video before coding — how to write a scene-by-scene spec, timing notation, levels of detail, and the blank spec template. A well-written spec = a buildable video on first pass.
---

# Spec Writing

A spec is a markdown document that describes a video precisely enough to build it. It sits between the raw script (what you want to say) and the code (what gets rendered).

> "Give me the freedom of a tight brief." — David Ogilvy

A clear spec doesn't limit creativity. It focuses it.

---

## Spec Structure

Every spec must have these four sections:

### 1. Overview

```markdown
## Overview
- **Duration:** ~3 minutes (5400 frames at 30fps)
- **Style:** Dark/cinematic
- **Resolution:** 1920×1080 @ 30fps
- **Target:** YouTube
- **Color palette:** Blue primary (#3B82F6), near-black background
```

### 2. Scene Breakdown

```markdown
### Scene 1: Hook (0:00–0:10)
**Duration:** 10s (frames 0–300)

**Narration:**
> "Exact voiceover text here."

**Visuals:**
- Frame 0–30:   Title slides up from below
- Frame 30–270: Title holds, subtitle fades in at frame 60
- Frame 270–300: Crossfade to Scene 2

**Components:** AnimatedText (hero), SceneContainer (dark)
**Notes:** Keep sparse — one focal point. No background motion during narration.
```

### 3. Color Flow (Optional But Valuable)

```markdown
## Color Flow
| Section    | Time      | Dominant Color | Mood        |
|---|---|---|---|
| Intro      | 0:00–0:30 | Blue           | Technical   |
| Problem    | 0:30–1:00 | Red            | Tension     |
| Solution   | 1:00–2:00 | Green          | Resolution  |
| Conclusion | 2:00–3:00 | Gold           | Premium     |
```

### 4. Global Notes

```markdown
## Global Notes
- Typography: body text minimum 48px, hero 72px+
- Animation default: `{ damping: 200 }` unless otherwise specified
- All scenes use SceneContainer background="dark"
- No decorative effects on background during voiceover
```

---

## Timing Notation

**Always write in seconds, convert to frames:**

| Duration | Seconds | Frames (30fps) |
|---|---|---|
| 0.5s | 0.5 | 15 |
| 1s | 1 | 30 |
| 2s | 2 | 60 |
| 5s | 5 | 150 |
| 10s | 10 | 300 |

**Formula:** `frames = seconds × fps`

In code, always comment frame values:
```tsx
const TITLE_IN = 15;   // 0.5s
const HOLD     = 90;   // 3s
```

---

## Levels of Detail

### Loose Spec (AI makes interpretive choices)

```markdown
### Scene 2: The Problem
Show the core problem with visual metaphor. Build tension.
Feel: dark, unsettling. Something is wrong.
Duration: ~15 seconds.
```

Use when: Early ideation, you trust the system's aesthetic judgment.

### Medium Spec (Guided Direction)

```markdown
### Scene 2: The Problem (0:10–0:25)
**Duration:** 15s (frames 300–750)
**Narration:** "Most teams ship code that nobody can maintain."

**Visuals:**
- Frame 300–330: GlitchText on "nobody can maintain" — red + chromatic shift
- Frame 330–600: Three code blocks stack in with stagger, each labeled "6 months later"
- Frame 600–750: All three fade out together
```

Use when: You have a specific visual idea but want execution flexibility.

### Tight Spec (You Direct Every Beat)

```markdown
### Scene 2 (frames 300–750)
- Frame 300: Black bg. Title "The Cost" fades in at center. 72px, textBright.
- Frame 330: `{ damping: 30, mass: 2 }` spring brings stat panel in from right.
- Frame 360: "47% of engineers..." CountUp from 0 to 47, Amber color.
- Frame 420: Underline drawn under "47%" over 20 frames.
```

Use when: You want pixel-level control or recreating a specific reference.

---

## Blank Spec Template

Copy this to `projects/[project-name]/spec.md`:

```markdown
# [Project Name]

## Overview
- **Duration:** ~X minutes (YYYY frames at 30fps)
- **Style:** [Dark/cinematic | bright/playful | technical/system | warm/historical]
- **Resolution:** 1920×1080 @ 30fps
- **Target:** [YouTube / Social / Presentation]
- **Color palette:** [Primary accent, background tone]

## Color Flow
| Section | Time | Dominant Color | Mood |
|---|---|---|---|
| [Section] | 0:00–0:XX | [Color] | [Mood] |

## Scene Breakdown

### Scene 1: [Name] (0:00–0:XX)
**Duration:** Xs (frames 0–XXX)

**Narration:**
> "Exact voiceover text here."

**Visuals:**
- Frame 0–30: [Entrance description]
- Frame 30–XX: [Main content]
- Frame XX–YY: [Exit / transition]

**Components:** [Which components to use]
**Notes:** [Emphasis, mood, pacing, what NOT to do]

---

<!-- Repeat for each scene -->

## Global Notes
- [Typography rules]
- [Color rules]
- [Animation defaults]

## Video Placeholder Locations
- Scene X, frames YYY–ZZZ: [Screen recording of ___]
- Scene Y, frames AAA–BBB: [Photo/screenshot of ___]
```

---

## Spec Review Checklist

Before handing a spec to the AI to build:

- [ ] Every scene has a frame range (`frames 0–300`)
- [ ] Narration text is exact — no paraphrasing
- [ ] At least a medium level of detail per scene
- [ ] Color Flow section filled in (even loosely)
- [ ] Global Notes includes typography baseline
- [ ] Video placeholder locations marked for any screen recordings or photos
