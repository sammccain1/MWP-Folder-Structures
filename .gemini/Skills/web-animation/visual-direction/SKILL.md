---
name: web-animation/visual-direction
description: Creative direction vocabulary for Remotion video specs. Load when writing a spec, reviewing existing scenes, or directing the visual feel of an animation — entrance types, emphasis effects, exit types, composition terms, and pacing language.
---

# Visual Direction Language

A shared vocabulary between creative direction and code. When a spec says "blur reveal" or "let it land," this is what it maps to technically.

---

## Entrances

| Term | Visual Effect | Implementation |
|---|---|---|
| **Fade in** | Opacity 0 → 1 | `interpolate(frame, [0, 30], [0, 1])` |
| **Slide up** | Translate from below + fade | `translateY` 50→0 + opacity 0→1 |
| **Slide in from left/right** | Horizontal translate + fade | `translateX` ±100→0 + opacity |
| **Pop in** | Scale 0.5→1 with bouncy spring | `spring({ damping: 12 })` |
| **Blur reveal** | Start blurred, sharpen word-by-word | BlurText component / CSS filter `blur()` animating 0 |
| **Type in** | Character by character | `text.slice(0, Math.floor(frame * 0.5))` |
| **Count up** | Number 0 → target | `Math.floor(spring * maxValue)` |
| **Build piece by piece** | Elements appear with stagger | Delayed springs per item |

---

## Emphasis

| Term | Visual Effect | When to Use |
|---|---|---|
| **Highlight** | Accent color + bold weight | Key terms introduced for first time |
| **Glow** | `text-shadow` or `box-shadow` pulse | Strong emotional emphasis |
| **Glitch** | Chromatic aberration / displacement | Error states, dramatic contrast |
| **Shine** | Animated shimmer across text | Positive reveal, premium feel |
| **Underline** | Animated underline draws in | Secondary emphasis, less dramatic |
| **Pulse** | Breathing scale/opacity loop | Ongoing importance, ambient alertness |

> **Rule:** Reserve emphasis effects for moments that matter. Using them everywhere means nothing stands out.

---

## Exits

| Term | Visual Effect |
|---|---|
| **Fade out** | Opacity 1 → 0 |
| **Fade to black** | Scene fades, background goes full black |
| **Slide out** | Translate away + fade |
| **Blur out** | Sharpen → blur |
| **Dissolve** | Crossfade into next scene (overlap) |

---

## Composition (Layout Language)

| Term | Meaning |
|---|---|
| **Centered** | Horizontally and vertically centered on screen |
| **Left-aligned** | Content anchored to left edge with safe margin |
| **Split** | Two columns or two halves side by side |
| **Stacked** | Vertical layout, elements top to bottom |
| **Sparse** | 1–2 elements, generous breathing room |
| **Dense** | 5+ elements, dashboard-like, information-rich |
| **Full bleed** | Element extends to screen edges (no margin) |

---

## Pacing

| Term | Meaning | Use When |
|---|---|---|
| **Quick cuts** | Scenes under 2 seconds each | Fast-paced energy, montage, rapid info |
| **Let it land** | Hold 3–5s after the key moment | Thesis moments, important reveals |
| **Build tension** | Slow entrance → pause before reveal | Narrative beats, suspense |
| **Rapid fire** | Fast staggered list, items < 0.5s apart | Reinforcing a point with data |
| **Breathe** | Slow spring, generous spacing, unhurried | Premium feel, heavy ideas |

---

## Visual Density Guidelines

| Level | Element Count | Best For |
|---|---|---|
| Sparse | 1–2 | Opening statements, quotes, key reveals |
| Medium | 3–4 | Comparisons, explanations, diagrams |
| Dense | 5+ | Summaries, system maps, timelines |

**Core rule:** Simpler visuals for complex ideas. Richer visuals for simple ideas. Never let the animation compete with the message.

---

## Mood-to-Spring Mapping

| Mood | Spring Config | Notes |
|---|---|---|
| Calm, authoritative | `{ damping: 200 }` | Slow, smooth — use for backgrounds and titles |
| Energetic, tech | `{ damping: 20, stiffness: 200 }` | Snappy — good for UI elements |
| Playful, fun | `{ damping: 8 }` | Bouncy — use sparingly |
| Weighty, dramatic | `{ damping: 30, mass: 2, stiffness: 80 }` | Heavy feel — big reveals |
| Attention-grabbing | `{ damping: 12, mass: 0.5, stiffness: 200 }` | Pop / bounce entrance |
