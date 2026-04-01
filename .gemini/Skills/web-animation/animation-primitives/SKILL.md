---
name: web-animation/animation-primitives
description: Core Remotion animation building blocks. Load when writing or debugging animation code — frame model, interpolate(), spring physics, spring configs, delayed springs, enter/exit patterns. The foundation everything else builds on.
---

# Animation Primitives

> **Critical rule:** ALL animations must use `useCurrentFrame()`. CSS transitions, CSS animations, and Tailwind animation classes are FORBIDDEN in Remotion — each frame is an independent React render; they will not play back.

---

## The Frame Model

```tsx
import { useCurrentFrame, useVideoConfig, interpolate, spring } from 'remotion';

export const MyScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames, width, height } = useVideoConfig();

  const opacity = interpolate(frame, [0, 30], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return <div style={{ opacity }}>Content</div>;
};
```

---

## Interpolation

Maps a frame number to any output value. **Always clamp.**

```tsx
// Fade in over 1 second (30 frames)
const opacity = interpolate(frame, [0, 1 * fps], [0, 1], { extrapolateRight: 'clamp' });

// Multi-step: fade in, hold, fade out
const opacity = interpolate(
  frame,
  [0, 30, 120, 150],   // keyframes
  [0, 1,   1,   0],   // values
  { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }
);

// Translate, scale, rotate
const translateY = interpolate(frame, [0, 30], [50, 0],  { extrapolateRight: 'clamp' });
const scale      = interpolate(frame, [0, 30], [0.5, 1], { extrapolateRight: 'clamp' });
const rotation   = interpolate(frame, [0, 60], [0, 360]);
```

---

## Spring Physics (Preferred)

Springs output 0→1. Combine with `interpolate()` to map to any range.

```tsx
const progress = spring({ frame, fps, config: { damping: 200 } });

const translateY = interpolate(progress, [0, 1], [50, 0]);
const scale      = interpolate(progress, [0, 1], [0.8, 1]);
```

### Spring Config Reference

| Config | Effect | Use For |
|---|---|---|
| `{ damping: 200 }` | Smooth, no bounce | Subtle reveals, backgrounds |
| `{ damping: 200, mass: 1, stiffness: 100 }` | Gentle, elegant | Standard entrances |
| `{ damping: 20, stiffness: 200, mass: 0.8 }` | Snappy | UI elements, quick reveals |
| `{ damping: 12, mass: 0.5, stiffness: 200 }` | Bouncy | Attention-grabbing entrances |
| `{ damping: 30, mass: 2, stiffness: 80 }` | Heavy, dramatic | Important moments |
| `{ damping: 8 }` | Very bouncy | Playful, cartoon-like |

---

## Delayed Springs (Stagger)

```tsx
// Method 1: subtract from frame
const progress = spring({ frame: frame - 15, fps, config: { damping: 200 } });

// Method 2: delay parameter
const progress = spring({ frame, fps, delay: 15, config: { damping: 200 } });
```

---

## Enter + Exit

```tsx
const { durationInFrames, fps } = useVideoConfig();

const entrance = spring({ frame, fps, config: { damping: 200 } });
const exit = spring({
  frame,
  fps,
  delay: durationInFrames - 1 * fps,  // start exit 1s before end
  durationInFrames: 1 * fps,
});

const opacity = entrance - exit;                                 // springs are just numbers
const scale   = interpolate(entrance - exit, [0, 1], [0.9, 1]);
```

---

## Easing (When Springs Don't Fit)

```tsx
import { Easing } from 'remotion';

const value = interpolate(frame, [0, 60], [0, 1], {
  easing: Easing.inOut(Easing.quad),
  extrapolateLeft: 'clamp',
  extrapolateRight: 'clamp',
});
// Options (least → most dramatic): linear, quad, sin, exp, circle
// Custom: Easing.bezier(x1, y1, x2, y2)
```

---

## Anti-Patterns

| Don't | Do Instead |
|---|---|
| CSS transitions/animations | `spring()` or `interpolate()` with `useCurrentFrame()` |
| Tailwind animation classes | Frame-based animation |
| `requestAnimationFrame` / `setTimeout` | Frame math (`frame - delay`) |
| `useState` for animation state | Derive everything from `frame` |
| Unclamped interpolation | Always set `extrapolateLeft/Right: 'clamp'` |
| Hardcoded frame numbers without comments | `const TITLE_IN = 15; // 0.5s` |
