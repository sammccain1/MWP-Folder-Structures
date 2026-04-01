---
name: ui-ux-design
description: UI/UX design patterns for hackathons and client web apps. Load when designing component systems, user flows, accessibility audits, or rapid prototyping. Covers design tokens, component hierarchy, WCAG accessibility, and hackathon-speed UI scaffolding with Tailwind and shadcn.
---

# UI/UX Design Skill

Design patterns for production-quality interfaces built at hackathon speed. Bridges the gap between "looks good" and "is actually usable and accessible."

---

## Hackathon UI Strategy

Winning hackathon UIs are judged in the first 10 seconds. Optimize for:
1. **One hero moment** — one visually memorable screen that communicates what the product does
2. **Clear user flow** — never more than 3 clicks to the core value
3. **Mobile-responsive** — judges often demo on phones
4. **Fake nothing** — if data doesn't exist yet, show realistic placeholders, not "lorem ipsum"

**Default stack for hackathons:** Next.js App Router + Tailwind + shadcn/ui + Framer Motion

---

## Design Token System

Establish these at project start in `globals.css` or `tailwind.config.ts`:

```typescript
// tailwind.config.ts
export default {
  theme: {
    extend: {
      colors: {
        brand: {
          50:  '#f0f9ff',
          500: '#0ea5e9',
          900: '#0c4a6e',
        },
        neutral: {
          50:  '#f8fafc',
          900: '#0f172a',
        },
      },
      fontFamily: {
        sans: ['var(--font-geist-sans)', 'system-ui'],
        mono: ['var(--font-geist-mono)', 'monospace'],
      },
      borderRadius: {
        DEFAULT: '0.5rem',
        lg: '0.75rem',
        xl: '1rem',
      },
    },
  },
}
```

**Never** use raw color names (`blue-500`) outside of the design token layer. Reference tokens instead.

---

## Component Hierarchy (Atomic Design)

```
src/components/
  ui/              # Primitive: Button, Input, Badge, Card (shadcn-generated)
  patterns/        # Composed: SearchBar, DataTable, EmptyState, LoadingSpinner
  features/        # Smart: UserDashboard, ProjectCard, AnalyticsChart
  layouts/         # Structural: AppShell, Sidebar, Header, PageWrapper
```

**Rule:** Components in `ui/` have zero business logic. Components in `features/` call services — never `fetch()` directly in JSX.

---

## Accessibility (WCAG 2.1 AA — Non-Negotiable for Client Work)

```typescript
// ✅ Accessible button
<button
  aria-label="Delete project"
  aria-describedby="delete-warning"
  onClick={handleDelete}
  className="..."
>
  <TrashIcon />
</button>
<p id="delete-warning" className="sr-only">This will permanently delete all project data.</p>

// ❌ Never
<div onClick={handleDelete}><TrashIcon /></div>
```

**Checklist before shipping any UI:**
- [ ] All interactive elements reachable by keyboard (Tab, Enter, Space, Esc)
- [ ] Color contrast ≥ 4.5:1 for body text, 3:1 for large text — check with browser DevTools > Accessibility
- [ ] All images have meaningful `alt` text (or `alt=""` if decorative)
- [ ] Form inputs have `<label>` or `aria-label`
- [ ] Error messages are associated with their field via `aria-describedby`
- [ ] Focus indicators are visible (`outline-offset-2 outline-brand-500`)

---

## User Flow Mapping Template

Before writing any code, map the flow:

```markdown
## Flow: [Feature Name]

**User Goal:** [What does the user want to accomplish?]

**Entry Points:**
- [Where does the user start? Dashboard? Email link? Direct URL?]

**Happy Path:**
1. User lands on [page]
2. User [action] → system [response]
3. User sees [outcome]

**Error States:**
- Empty state: [What shows when no data exists?]
- Loading state: [Skeleton? Spinner? Progress bar?]
- Error state: [What shows when the API fails?]
- Permission denied: [Redirected? Shown inline message?]

**Exit Points:**
- [Where does the flow end? Success screen? Back to dashboard?]
```

Implement empty/loading/error states **before** the happy path. Judges always see the edge cases.

---

## Rapid Prototyping Commands

```bash
# Add shadcn component
npx shadcn@latest add button card input dialog sheet table badge skeleton

# Add Framer Motion
npm install framer-motion

# Add standard icon set
npm install lucide-react
```

### Skeleton Pattern (Loading State)
```typescript
import { Skeleton } from "@/components/ui/skeleton"

function ProjectCardSkeleton() {
  return (
    <div className="space-y-3">
      <Skeleton className="h-4 w-[250px]" />
      <Skeleton className="h-4 w-[200px]" />
      <Skeleton className="h-10 w-full" />
    </div>
  )
}
```

### Empty State Pattern
```typescript
function EmptyState({ title, description, action }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-center">
      <FolderOpenIcon className="h-12 w-12 text-neutral-300 mb-4" />
      <h3 className="font-semibold text-neutral-900">{title}</h3>
      <p className="text-sm text-neutral-500 mt-1 mb-4">{description}</p>
      {action}
    </div>
  )
}
```

---

## Client Deliverable Standards

For client projects (not just hackathons), also require:

- [ ] Responsive at 375px (mobile), 768px (tablet), 1280px (desktop)
- [ ] Dark mode support via `dark:` Tailwind variants
- [ ] No horizontal scroll at any viewport
- [ ] Page load < 3s on simulated 4G (check Lighthouse)
- [ ] Lighthouse accessibility score ≥ 90
