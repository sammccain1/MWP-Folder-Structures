---
name: web-animation/composition-structure
description: Remotion composition architecture. Load when structuring a multi-scene video — how to define compositions, use Series vs Sequence, build the Root.tsx, and apply the scene template pattern.
---

# Composition Structure

---

## Folder Structure

```
src/
├── Root.tsx                       # All Composition definitions live here
├── components/core/               # Reusable primitives across all projects
│   ├── AnimatedText.tsx
│   ├── SceneContainer.tsx
│   └── effects/                   # GlitchText, ShinyText, etc.
├── compositions/ProjectName/
│   ├── index.tsx                  # Main composition (Series of scenes)
│   ├── scenes/                    # Individual scene components
│   ├── components/                # Project-specific only
│   └── constants/                 # colors.ts, timing.ts, typography.ts
└── styles/                        # Shared color + typography configs
```

---

## Defining a Composition

```tsx
// src/Root.tsx
import { Composition, Folder } from 'remotion';
import { MyVideo } from './compositions/MyVideo';

export const RemotionRoot = () => (
  <Folder name="Projects">
    <Composition
      id="MyVideo"
      component={MyVideo}
      durationInFrames={30 * 60 * 5}  // 5 min @ 30fps
      fps={30}
      width={1920}
      height={1080}
      defaultProps={{ title: 'My Video' }}
    />
  </Folder>
);
```

---

## Scene Sequencing

### Series (Sequential — Most Common)

Use `Series` when scenes play one after another with no overlap.

```tsx
import { Series } from 'remotion';

export const MyVideo: React.FC = () => (
  <Series>
    <Series.Sequence durationInFrames={150}><IntroScene /></Series.Sequence>
    <Series.Sequence durationInFrames={300}><MainScene /></Series.Sequence>
    <Series.Sequence durationInFrames={150}><OutroScene /></Series.Sequence>
  </Series>
);
```

### Sequence (Overlapping / Parallel)

Use `Sequence` when you need elements to overlap — background layers, persistent music, crossfades.

```tsx
import { Sequence, AbsoluteFill } from 'remotion';

export const MyVideo: React.FC = () => (
  <AbsoluteFill>
    {/* Background runs the whole time */}
    <Sequence from={0}><Background /></Sequence>

    {/* Scene at specific frame offsets */}
    <Sequence from={0}   durationInFrames={150}><IntroScene /></Sequence>
    <Sequence from={150} durationInFrames={300}><MainScene /></Sequence>

    {/* Music fades in during intro */}
    <Sequence from={60}><BackgroundMusic /></Sequence>
  </AbsoluteFill>
);
```

**Key difference:** `Series` handles offsets automatically. `Sequence` gives you exact frame placement and allows overlap.

---

## Scene Template

Every scene follows this structure. **Never skip the timeline marker constants.**

```tsx
import React from 'react';
import { AbsoluteFill, useCurrentFrame, useVideoConfig, spring, interpolate } from 'remotion';

// Timeline markers — comment the second equivalent
const INTRO      = 0;    // 0s
const TITLE_IN   = 15;   // 0.5s
const CONTENT_IN = 45;   // 1.5s
const FADE_OUT   = 140;  // 4.67s

export const MyScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const titleProgress   = spring({ frame: frame - TITLE_IN,   fps, config: { damping: 200 } });
  const contentProgress = spring({ frame: frame - CONTENT_IN, fps, config: { damping: 20, stiffness: 200 } });

  return (
    <AbsoluteFill style={{
      backgroundColor: '#0A0A0F',
      justifyContent: 'center',
      alignItems: 'center',
    }}>
      <div style={{
        opacity: titleProgress,
        transform: `translateY(${interpolate(titleProgress, [0, 1], [20, 0])}px)`,
        fontSize: 72,
        fontWeight: 700,
        color: '#E5E7EB',
      }}>
        Scene Title
      </div>

      <div style={{
        opacity: contentProgress,
        transform: `translateY(${interpolate(contentProgress, [0, 1], [30, 0])}px)`,
        fontSize: 48,
        color: '#9CA3AF',
        marginTop: 24,
      }}>
        Supporting content
      </div>
    </AbsoluteFill>
  );
};
```

---

## Special Composition Types

```tsx
// Thumbnail / social card (single frame)
<Still id="Thumbnail" component={Thumbnail} width={1280} height={720} />

// Dynamic duration (based on audio length, async data)
import { CalculateMetadataFunction } from 'remotion';

const calculateMetadata: CalculateMetadataFunction<Props> = async ({ props }) => ({
  durationInFrames: Math.ceil(props.audioDurationSec * 30),
  props: { ...props, resolvedData: await fetchData() },
});
```
