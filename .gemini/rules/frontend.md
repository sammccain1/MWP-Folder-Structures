# Frontend Rules

Stack: React + Next.js (App Router) + TypeScript strict mode

## TypeScript

- Strict mode on all `.ts` / `.tsx` files — no exceptions
- No `any` without a justification comment explaining why it's unavoidable
- All React components must define an explicit `interface Props` before the component
- Prefer `type` for unions and primitives, `interface` for object shapes

```typescript
// ✅ Correct
interface Props {
  userId: string;
  onSuccess: (user: User) => void;
}

export function UserCard({ userId, onSuccess }: Props) { ... }

// ❌ Anti-pattern — implicit props, no interface
export function UserCard({ userId, onSuccess }: any) { ... }
```

## Component Rules

- `"use client"` only when the component needs browser APIs, event handlers, or state
- Default to Server Components — fetch data directly, no `useEffect` for initial data
- Keep components small: if a component exceeds ~150 lines, split it
- No business logic in components — delegate to `src/services/`
- Never import from `components/` inside `services/` — dependency flows one way

## State Management

- Local UI state: `useState` / `useReducer`
- Server state: TanStack Query (`useQuery`, `useMutation`) — not `useEffect` + `fetch`
- Global app state: Zustand or React Context (context only for low-frequency updates)
- Never store derived state — compute it from source state

## Styling

- Tailwind utility classes — no custom CSS unless Tailwind can't express it
- No inline `style={{}}` for layout — use Tailwind
- Responsive by default: mobile-first (`sm:`, `md:`, `lg:`)
- Dark mode via `dark:` variants — no JS-based theme switching

## Next.js App Router Specifics

- Data fetching in `page.tsx` (Server Component) → pass as props to Client Components
- Server Actions in `actions.ts` with `"use server"` — call `revalidatePath()` after mutations
- Metadata via `generateMetadata()` — not `<Head>` tags
- Error boundaries: `error.tsx` per route segment
- Loading states: `loading.tsx` per route segment — don't use conditional rendering for skeleton states

## Performance

- Images: always use `next/image` — never raw `<img>`
- Fonts: `next/font` — never import from external CDN in production
- Dynamic imports for heavy components: `const Map = dynamic(() => import('./Map'), { ssr: false })`
- No `useEffect` with empty deps array for data that can be fetched server-side