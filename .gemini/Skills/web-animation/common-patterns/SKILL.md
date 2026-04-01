---
name: web-animation/common-patterns
description: Copy-paste animation patterns for Remotion. Load when implementing a specific motion effect — staggered lists, typewriter, counter, pulse, crossfade, and spin. Each pattern is plug-and-play with useCurrentFrame().
---

# Common Animation Patterns

All patterns assume `const frame = useCurrentFrame()` and `const { fps } = useVideoConfig()` are already declared.

---

## Staggered List Entrance

Items cascade in with a delay between each one.

```tsx
const items = ['First', 'Second', 'Third', 'Fourth'];
const STAGGER_DELAY = 4; // frames between each item (~0.13s at 30fps)

{items.map((item, index) => {
  const progress = spring({
    frame: frame - index * STAGGER_DELAY,
    fps,
    config: { damping: 20, stiffness: 200 },  // snappy
  });

  return (
    <div key={item} style={{
      opacity: progress,
      transform: `translateY(${interpolate(progress, [0, 1], [20, 0])}px)`,
    }}>
      {item}
    </div>
  );
})}
```

---

## Typewriter Effect

```tsx
const getTypedText = (frame: number, text: string, charsPerFrame = 0.5) => {
  const chars = Math.floor(frame * charsPerFrame);
  return text.slice(0, Math.min(chars, text.length));
};

// Usage
const visibleText = getTypedText(frame - startFrame, fullText, 0.5);

// With blinking cursor
const cursorOpacity = interpolate(frame % 16, [0, 8, 16], [1, 0, 1]);
<span style={{ opacity: cursorOpacity }}>▌</span>
```

---

## Pulsing / Breathing Effect

Gives elements a subtle "alive" ambient motion.

```tsx
// Gentle breathing (opacity)
const pulse = Math.sin(frame * 0.08) * 0.15 + 0.85;
<div style={{ opacity: pulse }}>Breathing element</div>

// Scale pulse
<div style={{ transform: `scale(${pulse})` }}>Pulsing element</div>
```

---

## Counter Animation

```tsx
const countTo = 1_000_000;
const progress = spring({ frame, fps, config: { damping: 200 } }); // smooth
const displayNumber = Math.floor(progress * countTo).toLocaleString();

// Output: "0" → "1,000,000" as the spring resolves
<div>{displayNumber}</div>
```

---

## Crossfade Between Sections

```tsx
const SECTION_A_END    = 100;
const SECTION_B_START  = 100;  // same frame = instant cut
const CROSSFADE_FRAMES = 30;   // 1 second overlap

const sectionAOpacity = interpolate(
  frame,
  [SECTION_A_END - CROSSFADE_FRAMES, SECTION_A_END],
  [1, 0],
  { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }
);

const sectionBOpacity = interpolate(
  frame,
  [SECTION_B_START, SECTION_B_START + CROSSFADE_FRAMES],
  [0, 1],
  { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }
);
```

---

## Fade to Black

```tsx
const FADE_START = durationInFrames - 30; // start 1s before end

const fadeToBlack = interpolate(
  frame,
  [FADE_START, durationInFrames],
  [0, 1],
  { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }
);

// Overlay on top of scene content
<AbsoluteFill style={{ backgroundColor: `rgba(0,0,0,${fadeToBlack})` }} />
```

---

## Rotating / Spinning Element

```tsx
// Rotate over a fixed duration
const rotation = interpolate(frame, [0, 60], [0, 360]);

// Continuous spin (2 degrees per frame = 1 full rotation per 3s)
const continuousRotation = frame * 2;

<div style={{ transform: `rotate(${rotation}deg)` }}>⚙️</div>
```

---

## Scale Pop (Bouncy Entrance)

```tsx
const bounce = spring({
  frame,
  fps,
  config: { damping: 12, mass: 0.5, stiffness: 200 }, // bouncy
});

<div style={{ transform: `scale(${bounce})`, opacity: bounce }}>
  Pop in!
</div>
```

---

## Component Decision Tree

When deciding which pattern to use:

```
KEY TERM introduced for first time?
  → ShinyText or emphasis with color + bold

GROWTH or SCALE numbers?
  → Counter animation

DRAMATIC reveal or thesis moment?
  → Blur reveal pattern (use BlurText component), slow spring

ERROR or PROBLEM?
  → GlitchText component, red emphasis

CODE or COMMANDS?
  → CodeBlock with monospace font

LIST of items?
  → Staggered list entrance

TRANSITION between sections?
  → Fade to black (section boundaries) or crossfade (within section)

AMBIENT / BACKGROUND ELEMENT?
  → Pulsing / breathing pattern, low opacity
```
