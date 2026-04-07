# React Rules

Guardrails for all React and Next.js component code across MWP projects.

---

## Component Structure

```tsx
// ✅ Standard component pattern — explicit Props interface, named export
interface CountyCardProps {
  countyName: string
  margin: number
  totalVotes: number
  onClick?: (fips: string) => void
}

export function CountyCard({ countyName, margin, totalVotes, onClick }: CountyCardProps) {
  const handleClick = () => onClick?.(countyName)

  return (
    <div className={styles.card} onClick={handleClick}>
      <h3>{countyName}</h3>
      <MarginBadge margin={margin} />
      <p>{totalVotes.toLocaleString()} votes</p>
    </div>
  )
}

// ❌ Never use default export for components (hard to refactor, breaks re-exports)
export default function CountyCard() { ... }

// ❌ Never use any — always type Props explicitly
function CountyCard(props: any) { ... }
```

---

## Hooks Rules

```tsx
// ✅ Always call hooks at the top level — never inside conditions or loops
function ElectionMap({ year }: { year: number }) {
  const [selectedFips, setSelectedFips] = useState<string | null>(null)
  const results = useElectionResults(year)   // custom hook

  // ❌ Never do this
  if (year > 2020) {
    const [data, setData] = useState(null)   // conditional hook — runtime error
  }
}
```

### useState

```tsx
// ✅ Use typed initial state
const [margin, setMargin] = useState<number | null>(null)
const [counties, setCounties] = useState<County[]>([])

// ✅ Functional update for state derived from previous state
setCount(prev => prev + 1)

// ❌ Never mutate state directly
counties.push(newCounty)         // doesn't trigger re-render
setCounties([...counties, newCounty])  // ✅ new array reference
```

### useEffect

```tsx
// ✅ Always declare dependencies, always return cleanup
useEffect(() => {
  const channel = supabase
    .channel('scores')
    .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'scores' }, handler)
    .subscribe()

  return () => supabase.removeChannel(channel)   // cleanup prevents memory leak
}, [])  // ← empty deps = run once on mount

// ✅ Fetch data with abort controller to prevent stale state
useEffect(() => {
  const controller = new AbortController()

  fetch(`/api/results?year=${year}`, { signal: controller.signal })
    .then(r => r.json())
    .then(setResults)
    .catch(err => { if (err.name !== 'AbortError') console.error(err) })

  return () => controller.abort()
}, [year])

// ❌ Never fetch without cleanup — causes state update on unmounted component
```

### useCallback / useMemo

```tsx
// ✅ useMemo for expensive derived values
const sortedCounties = useMemo(
  () => counties.slice().sort((a, b) => b.margin - a.margin),
  [counties]
)

// ✅ useCallback for stable function references passed to child components
const handleSelect = useCallback((fips: string) => {
  setSelectedFips(fips)
}, [])  // no deps — setSelectedFips is stable

// ❌ Don't wrap everything in memo — only when profiling shows a render problem
```

---

## Component Responsibilities

```tsx
// ✅ Components are for UI only — data fetching belongs in hooks or services
function ElectionTable({ results }: { results: County[] }) {
  // Only renders — doesn't fetch
  return <table>...</table>
}

// ✅ Extract data logic into a custom hook
function useElectionResults(year: number) {
  const [data, setData] = useState<County[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    setLoading(true)
    fetchResults(year)
      .then(setData)
      .catch(setError)
      .finally(() => setLoading(false))
  }, [year])

  return { data, loading, error }
}

// ❌ Never mix fetch logic directly into a component's render body
```

---

## Prop Passing

```tsx
// ✅ Destructure props — explicit and readable
function Badge({ label, color, size = 'md' }: BadgeProps) { ... }

// ✅ Spread only when forwarding all props to a DOM element
function Input({ className, ...rest }: InputProps) {
  return <input className={cn(styles.input, className)} {...rest} />
}

// ❌ Never spread unknown objects onto DOM elements — passes invalid HTML attributes
function Card({ data }: { data: Record<string, unknown> }) {
  return <div {...data} />   // may set invalid attrs, security risk
}
```

---

## Performance

```tsx
// ✅ Wrap pure child components in React.memo to skip unnecessary re-renders
export const CountyRow = React.memo(function CountyRow({ county }: CountyRowProps) {
  return <tr><td>{county.name}</td><td>{county.margin}</td></tr>
})

// ✅ Virtualize long lists — never render 3000 table rows to the DOM
import { FixedSizeList } from 'react-window'
<FixedSizeList height={600} itemCount={counties.length} itemSize={48} width="100%">
  {({ index, style }) => <CountyRow style={style} county={counties[index]} />}
</FixedSizeList>
```

---

## Error Boundaries

```tsx
// ✅ Wrap feature sections in error boundaries — don't let one widget crash the page
import { ErrorBoundary } from 'react-error-boundary'

<ErrorBoundary fallback={<p>Map failed to load. Try refreshing.</p>}>
  <ElectionMap year={2024} />
</ErrorBoundary>
```

---

## Rules Summary

| Rule | Rationale |
|---|---|
| Named exports only for components | Easier refactoring, better import autocomplete |
| Explicit `Props` interface on every component | TypeScript strict mode; no `any` |
| Hooks at top level only | React's rules of hooks — conditional hooks cause runtime errors |
| Always return cleanup from `useEffect` | Prevents memory leaks and stale state on unmount |
| Data fetching in hooks, not render body | Separation of concerns; testability |
| Never mutate state directly | React won't detect the change; use new references |
| `React.memo` only when profiling shows waste | Premature optimization adds complexity |
| Virtualize lists > 100 items | Direct DOM rendering 3000+ rows causes jank |
