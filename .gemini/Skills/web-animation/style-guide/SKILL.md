---
name: web-animation/style-guide
description: Remotion visual style standards. Load when making decisions about colors, typography, safe margins, or font stacks. These are the enforced minimums for 1920x1080 video — non-negotiable for readability.
---

# Style Guide

All standards assume **1920×1080 at 30fps**. Every value here is a minimum, not a suggestion.

---

## Color Palette

```typescript
// src/styles/colors.ts
export const COLORS = {
  // ── Backgrounds ──────────────────────────────────────────────
  background:  '#0A0A0F',   // Near-black — primary scene bg
  surface:     '#12121A',   // Cards, code blocks, panels
  surfaceAlt:  '#1A1A24',   // Nested elements, secondary panels

  // ── Text (contrast is non-negotiable) ────────────────────────
  text:        '#E5E7EB',   // Primary readable text
  textBright:  '#FFFFFF',   // Maximum contrast — hero moments
  textMuted:   '#9CA3AF',   // Secondary (non-essential info only)
  textDim:     '#6B7280',   // Badges, timestamps only — never body copy

  // ── Accent Colors ─────────────────────────────────────────────
  primary:  '#3B82F6',      // Blue — tech, links, trust
  accent:   '#10B981',      // Green — success, growth
  warning:  '#F59E0B',      // Amber — caution, insights
  danger:   '#EF4444',      // Red — errors, problems, bugs
  purple:   '#8B5CF6',      // AI, abstract ideas, creativity
  gold:     '#C9A227',      // Historical references, premium
};
```

### Color Psychology

| Color | Role | Use For |
|---|---|---|
| Blue `#3B82F6` | Trust / Technical | Code, concepts, system diagrams |
| Purple `#8B5CF6` | Abstract / AI | AI concepts, creativity, ideas |
| Amber `#F59E0B` | Alert / Insight | Important callouts, warnings |
| Green `#10B981` | Success / Growth | Solutions, positive outcomes |
| Red `#EF4444` | Error / Danger | Bugs, failure states, anti-patterns |
| Gold `#C9A227` | Premium / Historical | Historical references, key quotes |

**Rules:**
- Never use more than 3 emphasis colors per scene
- Backgrounds should always be dark and subdued — content is the focus
- `textMuted` and `textDim` are for genuinely non-essential info only; never use for primary content

---

## Typography

```typescript
// src/styles/typography.ts
export const TYPOGRAPHY = {
  display: { fontFamily: 'Inter, -apple-system, system-ui, sans-serif' },
  body:    { fontFamily: 'Inter, -apple-system, system-ui, sans-serif' },
  code:    { fontFamily: 'JetBrains Mono, Fira Code, Consolas, monospace' },
  quote:   { fontFamily: 'Playfair Display, Georgia, serif' },
};
```

### Minimum Font Sizes (1920×1080)

| Element | Minimum | Recommended |
|---|---|---|
| Hero / Title | **72px** | 84–108px |
| Section Header | **56px** | 64–72px |
| Body Text | **48px** | 56px |
| Subtext / Captions | **36px** | 40–44px |
| Code / Commands | **32px** | 36–40px |
| Labels / Annotations | **28px** | 32px |
| Badges / Tags | **18px** | 20–24px |

> These minimums exist because video gets re-encoded by YouTube/social platforms. Small text becomes unreadable after compression. **Never override these** for layout convenience.

---

## Safe Margins

```
Minimum:      5%   →  96px  at 1920 width
Recommended:  8%   →  154px at 1920 width
```

- **Never** place important content in the outer 5% — it may be cropped on some displays
- Use `SceneContainer` with `safeMargin="recommended"` to enforce this automatically
- Check safe margins visually in Remotion Studio with `<SafeAreaGuide margin={8} />` (dev only)

---

## Visual Density

| Density | Element Count | Use For |
|---|---|---|
| Sparse | 1–2 | Openings, quotes, "let it land" moments |
| Medium | 3–4 | Most explanations, comparisons, diagrams |
| Dense | 5+ | Summaries, system overviews, dashboards |

**Rule:** Complex ideas deserve simpler visuals. Simple ideas can carry richer visuals. Never let visual complexity compete with the message.
