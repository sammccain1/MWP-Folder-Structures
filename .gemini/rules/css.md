# CSS Rules

Guardrails for all CSS in React/Next.js projects. Applies to CSS Modules, global stylesheets, and any component-level styles.

---

## CSS Custom Properties (Required for Theming)

```css
/* globals.css or tokens.css — define once, use everywhere */
:root {
  /* Colors */
  --color-primary: hsl(221, 83%, 53%);
  --color-primary-dark: hsl(221, 83%, 40%);
  --color-surface: hsl(0, 0%, 98%);
  --color-text: hsl(0, 0%, 10%);
  --color-text-muted: hsl(0, 0%, 45%);

  /* Spacing scale */
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-4: 1rem;
  --space-8: 2rem;

  /* Typography */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
  --text-sm: 0.875rem;
  --text-base: 1rem;
  --text-lg: 1.125rem;
}
```

---

## No Inline Styles

```tsx
// ✅ Use CSS Modules or class names
<button className={styles.primaryButton}>Submit</button>

// ❌ Never inline styles for anything other than truly dynamic values
<button style={{ backgroundColor: 'blue', padding: '8px 16px' }}>Submit</button>

// ✅ Exception: truly dynamic values (e.g., map layer colors from data)
<div style={{ backgroundColor: `hsl(${hue}, 70%, 50%)` }} />
```

---

## CSS Modules (Preferred)

```css
/* components/MarginBadge.module.css */
.badge {
  display: inline-flex;
  align-items: center;
  padding: var(--space-1) var(--space-2);
  border-radius: 4px;
  font-size: var(--text-sm);
  font-weight: 600;
}

.dem { background-color: hsl(221, 83%, 92%); color: hsl(221, 83%, 30%); }
.rep { background-color: hsl(0, 83%, 92%); color: hsl(0, 83%, 30%); }
```

```tsx
import styles from './MarginBadge.module.css'
<span className={`${styles.badge} ${margin > 0 ? styles.dem : styles.rep}`}>
  {formatMargin(margin)}
</span>
```

---

## Responsive Design

```css
/* Mobile-first — base styles are for mobile */
.container {
  padding: var(--space-4);
  width: 100%;
}

/* Scale up for larger screens */
@media (min-width: 768px) {
  .container {
    padding: var(--space-8);
    max-width: 1200px;
    margin: 0 auto;
  }
}
```

**Standard breakpoints:**

| Name | Min Width | Use |
|---|---|---|
| `sm` | 640px | Large phones |
| `md` | 768px | Tablets |
| `lg` | 1024px | Laptops |
| `xl` | 1280px | Desktops |

---

## Accessibility (Color)

- **Text on background:** minimum contrast ratio **4.5:1** (WCAG AA)
- **Large text (>18px or bold >14px):** minimum **3:1**
- Never convey information by color alone — add an icon, label, or pattern

```bash
# Check contrast ratios
# Use: https://webaim.org/resources/contrastchecker/
# Or: npx pa11y http://localhost:3000
```

---

## Typography

```css
/* ✅ Use relative units for font sizes */
body { font-size: 1rem; }     /* 16px base */
h1 { font-size: 2rem; }       /* 32px */
small { font-size: 0.875rem; } /* 14px */

/* ❌ Avoid px for font sizes — breaks browser zoom accessibility */
body { font-size: 16px; }

/* ✅ Import Google Fonts in layout.tsx (Next.js) */
import { Inter } from 'next/font/google'
const inter = Inter({ subsets: ['latin'] })
```

---

## Rules Summary

| Rule | Rationale |
|---|---|
| Use CSS custom properties for tokens | Single source of truth for colors, spacing, type |
| No inline styles (except truly dynamic) | Maintainability, theming, prevents style conflicts |
| CSS Modules preferred over global classes | Scoped by component — no naming collisions |
| Mobile-first responsive design | Better baseline; progressive enhancement |
| Relative units (`rem`) for font sizes | Respects browser zoom settings (accessibility) |
| Min 4.5:1 color contrast | WCAG AA — required for accessibility compliance |
