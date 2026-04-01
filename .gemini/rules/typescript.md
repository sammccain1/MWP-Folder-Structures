# TypeScript Rules

Stack: TypeScript 5+, Next.js App Router, React 18+

## Type Safety

- **Strict mode is mandatory** — `"strict": true` in `tsconfig.json`. No exceptions.
- **Never use `any`** — use `unknown` when the type is genuinely unknown, then narrow it. `any` disables the entire type system for that value.
- **Avoid non-null assertions (`!`)** — handle `null`/`undefined` explicitly with optional chaining (`?.`) or guard clauses. `foo!.bar` hides real bugs.
- **Prefer `type` over `interface`** for most definitions — use `interface` only when you need declaration merging or extending a third-party type.
- **Never use `as` to force a type** unless you have verified the shape and added a comment explaining why. Use type guards instead.

```typescript
// ✅ Type guard
function isApiError(error: unknown): error is ApiError {
  return typeof error === 'object' && error !== null && 'code' in error;
}

// ❌ Force cast — hides bugs
const err = error as ApiError;
```

## Functions and Signatures

- **Explicit return types on all exported functions** — inference is fine internally, but exported APIs must be explicit.
- **Prefer `const` arrow functions** for component-level utilities; use `function` declarations for top-level service functions (hoisting matters for readability).
- **Never use `Function` as a type** — always specify the signature: `(event: MouseEvent) => void`.

```typescript
// ✅
export function fetchUser(id: string): Promise<User> { ... }
const handleClick = (e: React.MouseEvent<HTMLButtonElement>): void => { ... };

// ❌
export function fetchUser(id: string) { ... }  // implicit return type
const handleClick: Function = (e) => { ... };  // untyped Function
```

## Null and Optionality

- Use optional chaining (`?.`) and nullish coalescing (`??`) — never `||` for defaults on values that could legitimately be `0` or `""`.
- Return `null` from React components (invalid state) and `undefined` from functions (no value). These are semantically different.

```typescript
// ✅
const name = user?.profile?.displayName ?? 'Anonymous';
const count = metrics.value ?? 0;  // 0 is valid, don't override with ||

// ❌
const name = user && user.profile && user.profile.displayName || 'Anonymous';
```

## Generics

- Use generics when a function or type operates on multiple types without losing type information.
- Always constrain generics where possible: `<T extends object>` not just `<T>`.
- Name generic parameters descriptively beyond single letters for complex types: `TResponse`, `TEntity`.

```typescript
// ✅
async function fetchEntity<TEntity extends { id: string }>(
  endpoint: string,
  id: string
): Promise<TEntity> { ... }
```

## React + TypeScript

- **Always type component props** with a `type Props = { ... }` definition above the component. Never inline prop types.
- **Type event handlers** explicitly — `React.ChangeEvent<HTMLInputElement>`, `React.FormEvent<HTMLFormElement>`.
- **Never use `React.FC`** — it hides the return type and doesn't work well with generics. Write `const MyComponent = (props: Props): JSX.Element => { ... }` or use function declarations.

```typescript
// ✅
type Props = {
  label: string;
  onSelect: (value: string) => void;
  disabled?: boolean;
};

function SelectButton({ label, onSelect, disabled = false }: Props): JSX.Element {
  return <button onClick={() => onSelect(label)} disabled={disabled}>{label}</button>;
}

// ❌
const SelectButton: React.FC<{ label: string }> = ({ label }) => <button>{label}</button>;
```

## Enums and Literals

- **Prefer `const` objects with `as const` over enums** — enums compile to unexpected JavaScript and have footguns with string enums.

```typescript
// ✅
const STATUS = {
  PENDING:  'pending',
  ACTIVE:   'active',
  ARCHIVED: 'archived',
} as const;
type Status = typeof STATUS[keyof typeof STATUS]; // 'pending' | 'active' | 'archived'

// ❌
enum Status { Pending, Active, Archived }  // compiles to an IIFE, not tree-shakeable
```

## Imports and Module Boundaries

- Use path aliases (`@/components/...`) configured in `tsconfig.json` — never deep relative imports (`../../../../utils`).
- Group imports: external packages → internal aliases → relative. Never mix.
- Never import `type` values at runtime — use `import type { Foo }` for type-only imports so bundlers can drop them.
