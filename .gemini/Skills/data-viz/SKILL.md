---
name: data-viz
description: Data visualisation patterns for Sam's projects. Load when building charts, maps, or figures in Python (Matplotlib/Seaborn), R (ggplot2), or JavaScript (Mapbox GL). Includes plot structure templates, colour palettes, Mapbox layer recipes, and export standards.
---

# Data Viz Skill

Visualisation patterns for Python (Matplotlib/Seaborn), R (ggplot2), and Mapbox GL JS. Built around the project types in Sam's actual stack.

---

## Python — Matplotlib/Seaborn

### Figure Scaffold

```python
import matplotlib.pyplot as plt
import seaborn as sns

# Always set style at the top of a notebook or script
sns.set_theme(style="whitegrid", palette="muted", font_scale=1.2)

fig, ax = plt.subplots(figsize=(10, 6))

# --- your plot here ---

ax.set_title("Title", fontsize=14, fontweight="bold", pad=12)
ax.set_xlabel("X Label")
ax.set_ylabel("Y Label")
ax.tick_params(axis="both", labelsize=10)

plt.tight_layout()
plt.savefig("docs/figures/YYYY-MM-DD_figure-name.png", dpi=150, bbox_inches="tight")
plt.close()
```

### Save Convention
- All figures → `docs/figures/YYYY-MM-DD_figure-name.png`
- DPI: 150 for docs, 300 for print/reports
- Always `plt.close()` after saving in scripts (prevents memory leaks in loops)

### Palette Standards
```python
# Neutral sequential
PALETTE_SEQ = "Blues"

# Diverging (e.g., win margin)
PALETTE_DIV = "RdBu"

# Categorical (max 8 classes)
PALETTE_CAT = sns.color_palette("muted", n_colors=8)

# NCAA bracket seed colours (custom)
SEED_COLOURS = {
    1: "#1a6b3c", 2: "#2e8b57", 3: "#3cb371",
    4: "#6dbb8a", 5: "#a8d5b5", 6: "#d4eadc",
    7: "#f0e4c4", 8: "#e8c07d",
}
```

---

## R — ggplot2

### Plot Scaffold

```r
library(ggplot2)
library(dplyr)

# Consistent theme
theme_mwp <- function() {
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold", size = 15),
    axis.title    = element_text(size = 11),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )
}

# Usage
p <- ggplot(df, aes(x = seed, y = win_rate, fill = region)) +
  geom_col(position = "dodge") +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Win Rate by Seed",
    x = "Seed", y = "Win Rate",
    caption = "Source: toRvik"
  ) +
  theme_mwp()

ggsave("docs/figures/YYYY-MM-DD_win-rate-seed.png", p, width = 10, height = 6, dpi = 150)
```

### ggplot Anti-Patterns to Avoid
- Never use `geom_bar(stat="identity")` when `geom_col()` is available
- Never theme inside the function call body — always use `theme_mwp()` or `theme_set()`
- Never use default ggplot2 colours for more than 2 categories — use `scale_colour_brewer` or `scale_fill_brewer`

---

## Mapbox GL JS

### Layer Recipe — Choropleth

```javascript
// Add a choropleth layer from a GeoJSON source
map.addSource("counties", {
  type: "geojson",
  data: "/data/counties.geojson",
});

map.addLayer({
  id: "county-fill",
  type: "fill",
  source: "counties",
  paint: {
    "fill-color": [
      "interpolate", ["linear"],
      ["get", "value"],
      0,   "#edf8fb",
      25,  "#b2e2e2",
      50,  "#66c2a4",
      75,  "#2ca25f",
      100, "#006d2c",
    ],
    "fill-opacity": 0.75,
  },
});

map.addLayer({
  id: "county-outline",
  type: "line",
  source: "counties",
  paint: { "line-color": "#ffffff", "line-width": 0.5 },
});
```

### Layer Recipe — Point Clusters

```javascript
map.addSource("venues", {
  type: "geojson",
  data: "/data/venues.geojson",
  cluster: true,
  clusterMaxZoom: 14,
  clusterRadius: 50,
});

map.addLayer({
  id: "clusters",
  type: "circle",
  source: "venues",
  filter: ["has", "point_count"],
  paint: {
    "circle-color": ["step", ["get", "point_count"],
      "#51bbd6", 10, "#f1f075", 30, "#f28cb1"],
    "circle-radius": ["step", ["get", "point_count"], 20, 10, 30, 30, 40],
  },
});
```

### Mapbox Setup Checklist
- [ ] Token stored in `.env` as `MAPBOX_TOKEN`, never hardcoded
- [ ] GeoJSON files in `data/processed/` (not `data/raw/`)
- [ ] Map container has explicit `height: 600px` in CSS
- [ ] Add `map.on("error", console.error)` during development

---

## Export Standards

| Use Case | Format | DPI | Location |
|---|---|---|---|
| Inline notebook | PNG | 100 | Inline (not saved) |
| Docs / README | PNG | 150 | `docs/figures/` |
| Client report | PNG | 300 | `docs/figures/` |
| Interactive | HTML (Plotly/Mapbox) | N/A | `docs/` |
| Publication | SVG | Vector | `docs/figures/` |

---

## Common Mistakes

| Mistake | Fix |
|---|---|
| Saving figure before `tight_layout()` | Always call `tight_layout()` first |
| ggplot overwriting previous plot | Assign to variable `p <-`, always use `ggsave()` |
| Mapbox token in frontend JS | Use env var injected at build time |
| Default matplotlib figsize | Always set `figsize=(W, H)` explicitly |
| No colour-blind safe palette | Use `viridis`, `cividis`, or `ColorBrewer` palettes |
