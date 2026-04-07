# TypeScript Rules

Stack: TypeScript 5+, Next.js App Router, React 18+

Authored at senior-engineer level. Every rule has a rationale — understand the *why*,
not just the *what*.

---

## tsconfig.json — Required Settings

```json
{
  "compilerOptions": {
    "strict": true,              // enables all strict checks below
    "noUncheckedIndexedAccess": true,  // arr[0] is T | undefined — not just T
    "noImplicitReturns": true,   // every code path must return a value
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": true, // {a?: string} ≠ {a: string | undefined}
    "moduleResolution": "Bundler",
    "paths": { "@/*": ["./src/*"] }
  }
}
```

**Why `noUncheckedIndexedAccess`:** `arr[0]` returns `T | undefined` — not `T`. This one
flag catches more real bugs (null pointer style crashes) than any other tsconfig setting.
`strict: true` alone does not enable it.

**Why `exactOptionalPropertyTypes`:** Without it, `{ a?: string }` allows you to
explicitly set `a: undefined`. With it, optional means *absent* — not *undefined*. This
distinction matters at runtime in JSON serialization and API contracts.

---

## Type Safety

### Never `any`

```typescript
// ✅ Use unknown for genuinely unknown values — then narrow
function parseApiResponse(raw: unknown): ApiResult {
  if (!isApiResult(raw)) throw new TypeError('Unexpected API shape')
  return raw
}

// ✅ Type guard — narrow unknown to a specific shape
function isApiResult(v: unknown): v is ApiResult {
  return (
    typeof v === 'object' && v !== null &&
    'data' in v && 'status' in v &&
    typeof (v as { status: unknown }).status === 'number'
  )
}

// ❌ any disables the type system for the entire call chain
const data: any = response.json()
data.users.forEach((u: any) => ...)  // zero type safety from here
```

**Why:** `any` is contagious. One `any` at a boundary propagates through the entire call
graph. `unknown` forces you to prove the shape before using it.

### Never Non-Null Assertion (`!`)

```typescript
// ❌ Hides the real problem — crashes at runtime if null
const name = user!.profile!.displayName

// ✅ Handle null explicitly — this is where bugs live
function getDisplayName(user: User | null): string {
  if (!user) return 'Anonymous'
  return user.profile?.displayName ?? 'Anonymous'
}

// ✅ Guard clause pattern for early return
function processUser(user: User | null) {
  if (!user) throw new Error('User is required')
  // user is User from here — type narrowed
}
```

### Never `as` Without a Comment

```typescript
// ❌ Silences the type checker without proving safety
const el = document.getElementById('map') as HTMLCanvasElement

// ✅ Prove the shape with a guard, or document why the cast is safe
const el = document.getElementById('map')
if (!(el instanceof HTMLCanvasElement)) throw new Error('Expected canvas element')
// Now el: HTMLCanvasElement — proven, not asserted

// ✅ When as is unavoidable, document it
const event = e as React.ChangeEvent<HTMLInputElement> // Safe: handler is typed by React
```

---

## Advanced Type Patterns

### Discriminated Unions

```typescript
// ✅ Model state machines with discriminated unions — not optional fields
type FetchState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error }

function ResultView({ state }: { state: FetchState<County[]> }) {
  switch (state.status) {
    case 'idle':    return <p>Ready</p>
    case 'loading': return <Spinner />
    case 'success': return <CountyTable data={state.data} /> // data: County[] — guaranteed
    case 'error':   return <ErrorMessage error={state.error} />
  }
}

// ❌ Optional fields — is data present? Is error present? Who knows?
type BadState<T> = {
  loading: boolean
  data?: T
  error?: Error
}
// loading=false, data=undefined, error=undefined — is this idle or error? Ambiguous.
```

### Exhaustiveness Checking

```typescript
// ✅ Use never to guarantee the compiler catches missing cases
function assertNever(x: never): never {
  throw new Error(`Unhandled case: ${JSON.stringify(x)}`)
}

type Party = 'D' | 'R' | 'I'

function getPartyColor(party: Party): string {
  switch (party) {
    case 'D': return '#2166ac'
    case 'R': return '#b2182b'
    case 'I': return '#7b3f9e'
    default:  return assertNever(party) // compile error if a case is added and missed
  }
}
```

### Branded / Opaque Types

```typescript
// ✅ Prevent passing wrong string to wrong function at compile time
type FipsCode  = string & { readonly __brand: 'FipsCode' }
type StateCode = string & { readonly __brand: 'StateCode' }

function makeFips(raw: string): FipsCode {
  if (!/^\d{5}$/.test(raw)) throw new Error(`Invalid FIPS: ${raw}`)
  return raw as FipsCode
}

function getCountyResults(fips: FipsCode) { ... }

const code = makeFips('06037')
getCountyResults(code)   // ✅ compiles
getCountyResults('CA')   // ❌ compile error — string is not FipsCode
```

### Conditional Types

```typescript
// ✅ Extract the resolved value from a Promise
type Awaited<T> = T extends Promise<infer U> ? U : T

// ✅ Map over a union
type Nullable<T> = T extends any ? T | null : never

// ✅ Require at least one of a set of props
type RequireAtLeastOne<T, K extends keyof T = keyof T> =
  K extends keyof T ? Omit<T, K> & Required<Pick<T, K>> : never
```

### Mapped Types

```typescript
// ✅ Make all fields in a type readonly recursively
type DeepReadonly<T> = T extends object
  ? { readonly [K in keyof T]: DeepReadonly<T[K]> }
  : T

// ✅ Make specific fields required, rest optional
type WithRequired<T, K extends keyof T> = Omit<T, K> & Required<Pick<T, K>>

type PartialUser = Partial<User>
type UserWithRequiredEmail = WithRequired<PartialUser, 'email'>
```

### Template Literal Types

```typescript
// ✅ Type-safe event names
type EventName = `on${Capitalize<string>}`

// ✅ Type-safe CSS color tokens
type ColorToken = `--color-${string}`
type SpacingToken = `--space-${1 | 2 | 4 | 8 | 16}`

// ✅ API route typing
type ApiRoute = `/api/v1/${'results' | 'users' | 'auth'}${string}`
```

---

## Functions & Signatures

```typescript
// ✅ Explicit return types on all exported functions — inference leaks implementation details
export async function fetchResults(year: number): Promise<ElectionResult[]> {
  ...
}

// ✅ Function overloads for different call signatures
function getMargin(dem: number, rep: number): number
function getMargin(result: ElectionResult): number
function getMargin(demOrResult: number | ElectionResult, rep?: number): number {
  if (typeof demOrResult === 'object') {
    return (demOrResult.dem_votes - demOrResult.rep_votes) / demOrResult.total_votes
  }
  return (demOrResult - rep!) / (demOrResult + rep!)
}

// ❌ Never use Function as a type
type Handler = Function            // no argument or return type info
type Handler = () => void          // ✅ explicit
```

---

## Null & Optionality

```typescript
// ✅ Optional chaining + nullish coalescing
const name  = user?.profile?.displayName ?? 'Anonymous'
const count = metrics?.value ?? 0    // ?? not || — 0 is valid

// ❌ The || trap — overrides falsy values (0, '', false) unintentionally
const count = metrics?.value || 0   // 0 from API gets replaced with 0 anyway — harmless here
                                    // but metrics?.value || 'default' would override ''

// ✅ Nullish assignment
user.preferences ??= getDefaultPreferences()
```

---

## Error Handling — Result Type Pattern

```typescript
// ✅ Model fallible operations with a Result type — no throws across async boundaries
type Ok<T>  = { ok: true;  value: T }
type Err<E> = { ok: false; error: E }
type Result<T, E = Error> = Ok<T> | Err<E>

function ok<T>(value: T): Ok<T>   { return { ok: true,  value } }
function err<E>(error: E): Err<E> { return { ok: false, error } }

async function fetchResults(year: number): Promise<Result<ElectionResult[]>> {
  try {
    const data = await db.results.findMany({ where: { year } })
    return ok(data)
  } catch (e) {
    return err(e instanceof Error ? e : new Error(String(e)))
  }
}

// Call site — forced to handle both cases
const result = await fetchResults(2024)
if (!result.ok) {
  console.error(result.error)
  return
}
result.value.forEach(...)  // ElectionResult[] — guaranteed
```

---

## Generics

```typescript
// ✅ Constrain generics — don't use bare <T>
async function fetchEntity<TEntity extends { id: string }>(
  endpoint: string,
  id: string
): Promise<TEntity> { ... }

// ✅ Default generic parameters (TS 2.3+)
type ApiResponse<T = unknown> = {
  data: T
  status: number
  message: string
}

// ✅ Descriptive names beyond single letters for complex types
type Repository<TEntity extends Entity, TCreate extends object> = {
  findById(id: string): Promise<TEntity | null>
  create(payload: TCreate): Promise<TEntity>
  delete(id: string): Promise<void>
}
```

---

## Enums — Use `const` Objects

```typescript
// ❌ enum — compiles to an IIFE, leaks to runtime, not tree-shakeable, has reverse-mapping footguns
enum Status { Pending, Active, Archived }
Status[Status.Pending]  // "Pending" — reverse mapping, often surprising

// ✅ const object + derived type — same semantics, zero runtime overhead, tree-shakeable
const STATUS = {
  PENDING:  'pending',
  ACTIVE:   'active',
  ARCHIVED: 'archived',
} as const

type Status = typeof STATUS[keyof typeof STATUS]  // 'pending' | 'active' | 'archived'

// ✅ Iterate values if needed
const ALL_STATUSES = Object.values(STATUS)  // ['pending', 'active', 'archived']
```

---

## React + TypeScript

```typescript
// ✅ Explicit Props type (type alias not interface for components)
type CountyCardProps = {
  county: County
  isSelected: boolean
  onSelect: (fips: FipsCode) => void
  className?: string
}

// ✅ Named function declaration — not React.FC (hides return type, breaks generics)
export function CountyCard({ county, isSelected, onSelect, className }: CountyCardProps) {
  return (...)
}

// ✅ Generic components — not possible with React.FC
function Select<TValue extends string>({
  options,
  onChange,
}: {
  options: Array<{ label: string; value: TValue }>
  onChange: (value: TValue) => void
}) {
  return (...)
}

// ✅ forwardRef — explicit typing required
const Input = forwardRef<HTMLInputElement, InputProps>(function Input(
  { label, ...rest },
  ref
) {
  return <input ref={ref} {...rest} />
})

// ✅ Event handlers — always explicitly typed
const handleChange = (e: React.ChangeEvent<HTMLInputElement>): void => {
  setValue(e.target.value)
}

const handleSubmit = (e: React.FormEvent<HTMLFormElement>): void => {
  e.preventDefault()
  submit()
}
```

---

## Imports & Module Boundaries

```typescript
// ✅ Path aliases — never relative traversal
import { fetchResults } from '@/services/electionService'
import type { ElectionResult } from '@/types'

// ❌ Deep relative imports — break on refactor
import { fetchResults } from '../../../../services/electionService'

// ✅ type-only imports — bundlers can drop them entirely
import type { County, FipsCode } from '@/types'

// ✅ Import grouping order (enforced by ESLint import/order)
// 1. Node built-ins (fs, path)
// 2. External packages (react, next, zod)
// 3. Internal aliases (@/services, @/components)
// 4. Relative imports (./utils)
// Each group separated by a blank line
```

---

## Async Patterns

```typescript
// ✅ Parallel fetches — Promise.all, not sequential await
const [results, metadata] = await Promise.all([
  fetchResults(year),
  fetchMetadata(year),
])

// ✅ Promise.allSettled when partial failure is acceptable
const settled = await Promise.allSettled(counties.map(c => fetchCountyData(c.fips)))
const successes = settled
  .filter((r): r is PromiseFulfilledResult<CountyData> => r.status === 'fulfilled')
  .map(r => r.value)

// ✅ Type-safe filter — user-defined type guard as the predicate
const defined = values.filter((v): v is NonNullable<typeof v> => v != null)

// ❌ Don't float Promises — always await or return
async function saveResult() {
  fetchAndSave()   // floating promise — errors are swallowed silently
}
async function saveResult() {
  await fetchAndSave()   // ✅
}
```

---

## Rules Summary

| Rule | Rationale |
|---|---|
| `noUncheckedIndexedAccess: true` | Catches the most common runtime crash — `arr[0]` may be undefined |
| `exactOptionalPropertyTypes: true` | Optional means absent, not `undefined` — prevents serialization bugs |
| Never `any` — use `unknown` + narrowing | `any` is contagious; `unknown` enforces proof before use |
| Never `!` assertion | Crashes silently at runtime; handle null explicitly |
| Discriminated unions over optional fields | Makes impossible states unrepresentable at the type level |
| Exhaustiveness with `assertNever` | Compiler catches missing switch cases when the union grows |
| Branded types for domain primitives | Prevents confusing `fips` with `state_code` at compile time |
| Never `enum` — use `const` + `as const` | Enums compile to IIFE bloat; `const` objects are tree-shakeable |
| Explicit return types on exports | Prevents implementation details from leaking into the public API |
| `import type` for type-only imports | Enables correct dead-code elimination in bundlers |
| Result type for fallible async ops | No surprise throws across await boundaries; errors are explicit |
| `Promise.all` for parallel fetches | Sequential awaits are 2-3x slower than parallel when independent |
