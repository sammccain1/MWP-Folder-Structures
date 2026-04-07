# Frontend Rules

Stack: React 18 + Next.js App Router + TypeScript strict mode

---

## Server vs Client Components

```tsx
// ✅ Default: Server Component — fetch directly, no useEffect, no useState
// app/results/page.tsx
import { fetchElectionResults } from '@/services/electionService'
import { ElectionTable } from '@/components/ElectionTable'

export default async function ResultsPage({ searchParams }: { searchParams: { year: string } }) {
  const year = parseInt(searchParams.year) || 2024
  const results = await fetchElectionResults(year)  // direct async call — no useEffect needed

  return <ElectionTable results={results} />
}

// ✅ Client Component — only when you need interactivity, state, or browser APIs
'use client'

import { useState } from 'react'
import { CountyCard } from '@/components/CountyCard'

export function InteractiveMap({ counties }: { counties: County[] }) {
  const [selected, setSelected] = useState<string | null>(null)

  return (
    <div>
      {counties.map(c => (
        <CountyCard
          key={c.fips}
          county={c}
          isSelected={selected === c.fips}
          onSelect={setSelected}
        />
      ))}
    </div>
  )
}

// ❌ Don't add 'use client' unless you need it — server components are faster
// ❌ Don't fetch in useEffect when you can fetch in a Server Component
```

---

## TypeScript

```typescript
// ✅ Every component has an explicit Props type above it
type Props = {
  userId: string
  onSuccess: (user: User) => void
  className?: string
}

export function UserCard({ userId, onSuccess, className }: Props) { ... }

// ✅ Narrow union types with type guards rather than casting
function isApiError(err: unknown): err is { message: string; code: number } {
  return typeof err === 'object' && err !== null && 'code' in err
}

// ❌ Never any, never non-null assertion without comment
const data: any = response.data          // disables type checking
const name = user!.profile!.name         // crashes if undefined
```

---

## State Management

### Local State

```tsx
// ✅ useState for simple local UI state
const [isOpen, setIsOpen] = useState(false)

// ✅ useReducer for complex state with multiple sub-values
type FilterState = { year: number; state: string; party: 'D' | 'R' | 'all' }
type FilterAction = { type: 'SET_YEAR'; year: number } | { type: 'SET_STATE'; state: string }

const [filters, dispatch] = useReducer(filterReducer, { year: 2024, state: 'all', party: 'all' })

// ❌ Never store derived state
const [filteredCount, setFilteredCount] = useState(0)  // compute from source
const filteredCount = counties.filter(c => c.state === filters.state).length  // ✅
```

### Server State — TanStack Query

```tsx
// ✅ Use TanStack Query for client-side data that needs refetch, cache, loading states
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'

function CountyResults({ year }: { year: number }) {
  const { data, isLoading, error } = useQuery({
    queryKey: ['results', year],
    queryFn: () => fetch(`/api/results/${year}`).then(r => r.json()),
    staleTime: 60_000,  // consider data fresh for 60s
  })

  if (isLoading) return <ResultsSkeleton />
  if (error) return <ErrorMessage error={error} />
  return <ResultsTable data={data} />
}

// ✅ useMutation for write operations
const queryClient = useQueryClient()
const { mutate: saveResult } = useMutation({
  mutationFn: (data: ResultPayload) => fetch('/api/results', { method: 'POST', body: JSON.stringify(data) }),
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['results'] }),
})

// ❌ Don't use useEffect + useState + fetch for server data — use TanStack Query
```

### Global State — Zustand

```tsx
// stores/mapStore.ts
import { create } from 'zustand'

type MapStore = {
  selectedFips: string | null
  zoom: number
  setSelectedFips: (fips: string | null) => void
  setZoom: (zoom: number) => void
}

export const useMapStore = create<MapStore>((set) => ({
  selectedFips: null,
  zoom: 4,
  setSelectedFips: (fips) => set({ selectedFips: fips }),
  setZoom: (zoom) => set({ zoom }),
}))

// ✅ Use only for UI state that genuinely spans components (map selection, theme, sidebar open)
// ❌ Don't put server data in Zustand — that's TanStack Query's job
```

---

## Server Actions

```typescript
// app/actions/results.ts
'use server'

import { revalidatePath } from 'next/cache'
import { getServerSession } from 'next-auth'
import { z } from 'zod'

const Schema = z.object({
  fips: z.string().length(5),
  demVotes: z.number().int().nonnegative(),
})

export async function submitResult(formData: FormData) {
  const session = await getServerSession()
  if (!session) throw new Error('Unauthorized')   // always auth-check

  const parsed = Schema.safeParse({
    fips: formData.get('fips'),
    demVotes: Number(formData.get('demVotes')),
  })
  if (!parsed.success) throw new Error('Validation failed')

  await db.results.upsert({ where: { fips: parsed.data.fips }, data: parsed.data })
  revalidatePath('/results')            // ✅ always revalidate affected pages
}
```

---

## Next.js App Router Conventions

```
app/
├── layout.tsx          — root layout (fonts, providers, nav)
├── page.tsx            — home page (Server Component)
├── error.tsx           — error boundary for this route segment
├── loading.tsx         — loading skeleton for this segment
├── not-found.tsx       — 404 for this segment
├── results/
│   ├── page.tsx        — server-fetches and renders ResultsTable
│   ├── [year]/
│   │   └── page.tsx    — dynamic segment
│   └── layout.tsx      — shared layout for /results/**
└── api/
    └── results/
        └── route.ts    — API route handler (GET/POST)
```

- Data fetching in `page.tsx` (Server Component) → pass as props to Client Components
- Metadata via `export async function generateMetadata()` — not `<Head>` tags
- Use `loading.tsx` per segment — don't conditionally render skeletons in components
- Use `error.tsx` per segment — don't try-catch render errors in components

---

## Performance

```tsx
// ✅ next/image — auto WebP, lazy load, prevents CLS
import Image from 'next/image'
<Image src="/map.png" alt="Election map" width={1200} height={800} priority />

// ✅ next/font — self-hosted, no layout shift, no external CDN request
import { Inter } from 'next/font/google'
const inter = Inter({ subsets: ['latin'], display: 'swap' })

// ✅ Dynamic import — defer heavy components (maps, charts) from initial bundle
const ElectionMap = dynamic(() => import('@/components/ElectionMap'), {
  ssr: false,           // Mapbox GL doesn't run server-side
  loading: () => <MapSkeleton />,
})

// ❌ Never raw <img> for user-facing content
// ❌ Never import Google Fonts via <link> in production
// ❌ Never useEffect with empty deps for data that can be fetched server-side
```

---

## Styling

```tsx
// ✅ CSS Modules — scoped, no collisions
import styles from './CountyCard.module.css'
<div className={styles.card}>

// ✅ clsx/cn for conditional classes
import { cn } from '@/utils/cn'
<div className={cn(styles.badge, isWinner && styles.winner)}>

// ❌ Never inline styles for layout or static values
<div style={{ display: 'flex', gap: '8px' }}>     // use CSS
<div style={{ color: '#b2182b' }}>                // use CSS custom properties

// ✅ Only truly dynamic values justify inline styles
<div style={{ backgroundColor: `hsl(${hue}, 70%, 50%)` }}>   // data-driven color
```

---

## Rules Summary

| Rule | Rationale |
|---|---|
| Server Components by default | Faster; no client JS shipped; direct async data fetch |
| `'use client'` only when needed | Every unnecessary Client Component increases JS bundle |
| Explicit `Props` type on every component | TypeScript strict mode; self-documenting |
| TanStack Query for server state | Handles loading, error, cache, refetch — no useEffect boilerplate |
| Zustand for global UI state only | Not for server data; keeps components decoupled |
| Always auth-check in Server Actions | Actions are exposed to the network — no implicit trust |
| `revalidatePath()` after every mutation | Ensures cached pages reflect new data |
| `next/image` not `<img>` | Automatic optimization, lazy loading, CLS prevention |