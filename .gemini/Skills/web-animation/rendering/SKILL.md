---
name: web-animation/rendering
description: Remotion render commands and codec selection. Load when running a final render, exporting for a video editor, or optimizing render performance. Covers ProRes vs H.264 tradeoffs, CRF reference, concurrency tuning, and troubleshooting.
---

# Rendering

---

## Codec Selection

| Use Case | Codec | File Size | Notes |
|---|---|---|---|
| **Editing in NLE** (DaVinci, Premiere, CapCut) | ProRes 4444 | Large (1–3GB / 14min) | No keyframe artifacts, every frame independent |
| **Direct upload** (YouTube, social) | H.264 CRF 10 | Medium | Near-lossless, may show artifacts if re-encoded by NLE |
| **Quick preview** | H.264 CRF 23 | Small | Fast, good enough to check timing and motion |

> **Default workflow:** Render ProRes → bring into video editor → export final from editor. Never skip the NLE step for client deliverables.

---

## Render Commands

```bash
# Studio preview (browser, live reload)
npx remotion studio

# ProRes for editing — recommended workflow
npx remotion render src/index.ts CompositionName out/video-prores.mov \
  --codec prores \
  --prores-profile 4444 \
  --jpeg-quality 100 \
  --width 1920 --height 1080 \
  --concurrency 16

# H.264 near-lossless — direct upload
npx remotion render src/index.ts CompositionName out/video-1080p.mp4 \
  --codec h264 \
  --crf 10 \
  --jpeg-quality 100 \
  --width 1920 --height 1080 \
  --concurrency 16

# Quick preview — half resolution
npx remotion render src/index.ts CompositionName out/preview.mp4 \
  --codec h264 \
  --crf 23 \
  --scale 0.5 \
  --concurrency 16
```

---

## CRF Reference (H.264)

| CRF | Quality Level | Use For |
|---|---|---|
| 10 | Near-lossless | Final renders for direct upload |
| 15 | High | Good balance of size and quality |
| 18 | Visually lossless | YouTube (gets re-encoded anyway) |
| 23 | Good | Previews and timing checks |

Lower CRF = higher quality = larger file size.

---

## Performance

- Set `--concurrency` to roughly your CPU thread count (e.g., 16 for 8-core)
- ProRes renders faster than H.264 because there's no encoding step
- Use `--scale 0.5` for previews — cuts render time significantly
- Avoid rendering at 4K if the composition is designed at 1080p

---

## Asset Handling

```tsx
// Images — use staticFile() for bundled assets
import { Img, staticFile } from 'remotion';
<Img src={staticFile('logo.png')} />

// Remote images (ensure CORS is allowed on source)
<Img src="https://example.com/image.png" />

// Audio
import { Audio, staticFile } from 'remotion';
<Audio src={staticFile('music.mp3')} />

// Fonts — load before composition renders
import { loadFont } from '@remotion/fonts';
await loadFont({ family: 'Inter', weights: ['400', '700'] });
```

---

## Troubleshooting

| Issue | Cause | Fix |
|---|---|---|
| Animation doesn't play | Using CSS transitions | Switch to `useCurrentFrame()` + `spring`/`interpolate` |
| Checkerboard artifacts in NLE | H.264 keyframe compression | Render with ProRes instead |
| Elements too small | Higher resolution than composition | Stick with designed resolution (1920×1080) |
| Spring too slow / fast | Wrong damping/stiffness | Adjust config — see animation-primitives skill |
| Values go out of range | Unclamped interpolation | Add `extrapolateLeft/Right: 'clamp'` |
| Render crashes | Too many concurrent renders | Lower `--concurrency` |
| Blank frames | Component not handling frames before delay | Guard: `if (frame - DELAY < 0) return null` |
