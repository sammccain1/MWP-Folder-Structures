---
name: geospatial
description: Geospatial and political map patterns — Mapbox GL JS layers, GeoJSON data structures, choropleth maps, turf.js spatial operations, and R sf/tigris workflows. Load for any political map, geographic data visualization, or spatial analysis task.
---

# Geospatial Skill

Patterns for political maps, geographic data visualization, and spatial analysis using Sam's primary stack: **Mapbox GL JS**, **GeoJSON**, **turf.js**, **R sf/tigris**, and **Python geopandas**.

---

## Mapbox GL JS — Setup

```typescript
// components/MapView.tsx
import mapboxgl from 'mapbox-gl'
import 'mapbox-gl/dist/mapbox-gl.css'
import { useEffect, useRef } from 'react'

mapboxgl.accessToken = process.env.NEXT_PUBLIC_MAPBOX_TOKEN!

export default function MapView() {
  const mapContainer = useRef<HTMLDivElement>(null)
  const map = useRef<mapboxgl.Map | null>(null)

  useEffect(() => {
    if (map.current || !mapContainer.current) return

    map.current = new mapboxgl.Map({
      container: mapContainer.current,
      style: 'mapbox://styles/mapbox/dark-v11',  // dark base for political maps
      center: [-98.5795, 39.8283],               // US center
      zoom: 4,
    })

    map.current.on('load', () => {
      addElectionLayer(map.current!)
    })

    return () => map.current?.remove()
  }, [])

  return <div ref={mapContainer} style={{ width: '100%', height: '100vh' }} />
}
```

---

## Choropleth Map — County Level Election Results

```typescript
function addElectionLayer(map: mapboxgl.Map) {
  // Add GeoJSON source — county boundaries + election data joined
  map.addSource('counties', {
    type: 'geojson',
    data: '/data/counties-with-results.geojson',
  })

  // Fill layer — color by party margin
  map.addLayer({
    id: 'county-fill',
    type: 'fill',
    source: 'counties',
    paint: {
      'fill-color': [
        'interpolate', ['linear'],
        ['get', 'dem_margin'],    // -1.0 (deep R) to +1.0 (deep D)
        -1,   '#b2182b',          // deep red
        -0.2, '#ef8a62',          // light red
        0,    '#f7f7f7',          // toss-up
        0.2,  '#67a9cf',          // light blue
        1,    '#2166ac',          // deep blue
      ],
      'fill-opacity': 0.85,
    },
  })

  // Stroke layer
  map.addLayer({
    id: 'county-stroke',
    type: 'line',
    source: 'counties',
    paint: {
      'line-color': '#333',
      'line-width': 0.5,
    },
  })

  // Hover tooltip
  map.on('mousemove', 'county-fill', (e) => {
    const props = e.features?.[0]?.properties
    if (!props) return
    new mapboxgl.Popup({ closeButton: false })
      .setLngLat(e.lngLat)
      .setHTML(`<strong>${props.county_name}</strong><br/>D+${(props.dem_margin * 100).toFixed(1)}%`)
      .addTo(map)
  })
}
```

---

## GeoJSON Patterns

```typescript
// Standard FeatureCollection structure
const countyData: GeoJSON.FeatureCollection = {
  type: 'FeatureCollection',
  features: results.map(row => ({
    type: 'Feature',
    properties: {
      fips: row.fips,
      county_name: row.county,
      dem_margin: row.dem_votes / row.total_votes - row.rep_votes / row.total_votes,
    },
    geometry: row.geometry,  // polygon from census shapefile
  }))
}
```

---

## R — Fetching Census Boundaries with tigris

```r
library(tigris)
library(sf)
library(dplyr)

# Download US county boundaries
counties <- counties(cb = TRUE, resolution = "20m", year = 2022) |>
  st_transform(4326)  # WGS84 for Mapbox compatibility

# Join with election results
results <- read_csv("data/raw/election_results.csv")

counties_with_results <- counties |>
  left_join(results, by = c("GEOID" = "fips")) |>
  mutate(dem_margin = dem_votes / total_votes - rep_votes / total_votes)

# Export as GeoJSON for Mapbox
st_write(counties_with_results, "data/processed/counties-with-results.geojson",
         delete_dsn = TRUE)
```

---

## Python — geopandas Spatial Join

```python
import geopandas as gpd
import pandas as pd

# Load shapefile + results
counties = gpd.read_file("data/raw/counties.shp").to_crs(epsg=4326)
results = pd.read_csv("data/raw/election_results.csv", dtype={"fips": str})

# Join
merged = counties.merge(results, left_on="GEOID", right_on="fips", how="left")

# Compute margin
merged["dem_margin"] = (
    merged["dem_votes"] / merged["total_votes"]
    - merged["rep_votes"] / merged["total_votes"]
)

# Export GeoJSON
merged.to_file("data/processed/counties-with-results.geojson", driver="GeoJSON")
```

---

## turf.js — Spatial Operations

```typescript
import * as turf from '@turf/turf'

// Check if a point is inside a county polygon
const point = turf.point([-87.6298, 41.8781])  // Chicago
const isInCook = turf.booleanPointInPolygon(point, cookCountyPolygon)

// Calculate centroid for label placement
const centroid = turf.centroid(countyFeature)

// Buffer a point (e.g., 50-mile radius around a city)
const buffer = turf.buffer(point, 50, { units: 'miles' })
```

---

## Data Sources

| Source | Data | Access |
|---|---|---|
| US Census TIGER | County/state/CD boundaries | `tigris` (R) or direct download |
| MIT Election Lab | Presidential/Senate results | CSV download |
| OpenElections | Precinct-level results | GitHub |
| Mapbox | Base map styles | API key via `NEXT_PUBLIC_MAPBOX_TOKEN` |
| Natural Earth | Country boundaries (low-res) | Free download |

---

## Rules

- Always transform geometries to **WGS84 (EPSG:4326)** before passing to Mapbox
- Never commit raw shapefiles (`.shp`, `.dbf`, `.shx`) to git — add to `.gitignore`
- Store processed GeoJSON in `data/processed/` — source shapefiles in `data/raw/`
- FIPS codes must be stored as strings (zero-padded: `"01001"` not `1001`)
- Use `cb = TRUE` in `tigris` for cartographic (simplified) boundaries unless you need full precision

---

## When to Load This Skill

- Building a political map or geographic data visualization
- Joining election results to county/state/CD boundaries
- Writing `tigris` or `sf` code in R
- Writing `geopandas` spatial operations in Python
- Adding Mapbox GL JS layers to a Next.js app
- Converting between shapefile, GeoJSON, or Parquet geospatial formats
