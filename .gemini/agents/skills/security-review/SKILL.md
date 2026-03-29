---
name: security-review
description: Full-stack security review skill. Provides vulnerability patterns, code examples, report templates, and stack-specific rules for Python/FastAPI, TypeScript/Next.js, PostgreSQL, and Supabase projects. Load when reviewing auth code, API endpoints, user input handling, or running pre-release security sweeps.
---

# Security Review Skill

Detailed security patterns, code examples, and full-stack rules to accompany the `security-auditor` agent. Covers Sam's primary stack: **Python/FastAPI**, **TypeScript/Next.js**, **PostgreSQL**, **Supabase**, and **Vercel deployments**.

---

## Full-Stack Security Rules

### Python / FastAPI

```python
# ✅ Parameterized queries — never interpolate user input
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))

# ✅ Never mutate — return new validated objects
from pydantic import BaseModel, validator

class UserInput(BaseModel):
    email: str
    password: str

    @validator("email")
    def email_must_be_valid(cls, v):
        if "@" not in v:
            raise ValueError("Invalid email")
        return v.lower().strip()

# ✅ Hash passwords with bcrypt — never store plaintext
import bcrypt
hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt())

# ❌ Never do this
query = f"SELECT * FROM users WHERE email = '{email}'"  # SQL injection
os.system(f"echo {user_input}")  # Shell injection
```

**Mandatory FastAPI rules:**
- All endpoints that modify data must require authentication via `Depends(get_current_user)`
- Use `HTTPException` — never expose raw exception messages to clients
- Rate-limit all auth endpoints (`slowapi` or `fastapi-limiter`)
- Validate all request bodies with Pydantic models (strict types, no `Any`)
- Mount CORS with an explicit `allow_origins` list — never `["*"]` in production

---

### TypeScript / Next.js

```typescript
// ✅ Escape output — never dangerously set HTML
<p>{userContent}</p>  // Safe — React escapes by default
// ❌ NEVER do this
<div dangerouslySetInnerHTML={{ __html: userContent }} />

// ✅ Server Actions / API Routes — always validate and authenticate
import { getServerSession } from "next-auth"

export async function POST(req: Request) {
  const session = await getServerSession(authOptions)
  if (!session) return new Response("Unauthorized", { status: 401 })

  const body = await req.json()
  const parsed = schema.safeParse(body)  // Zod validation
  if (!parsed.success) return new Response("Bad Request", { status: 400 })

  // proceed with parsed.data
}

// ✅ SSRF prevention — whitelist external URLs
const ALLOWED_DOMAINS = ["api.trusted.com", "cdn.trusted.com"]
const url = new URL(userProvidedUrl)
if (!ALLOWED_DOMAINS.includes(url.hostname)) throw new Error("Forbidden")
```

**Mandatory Next.js rules:**
- Every API route and Server Action must verify session before touching data
- Use Zod (or equivalent) to validate all request bodies and query params
- Set security headers in `next.config.js`: `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy`
- Never expose `NEXT_PUBLIC_` env vars that contain secrets
- Middleware auth should protect all `/api/` and `/dashboard/` routes as a catch-all safety net

---

### PostgreSQL / Supabase

```sql
-- ✅ Row Level Security — enable on every table that stores user data
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only see their own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = user_id);

-- ✅ Least privilege — service roles only for admin ops
-- ❌ Never use the Supabase service_role key client-side
```

**Mandatory DB rules:**
- Enable RLS on all Supabase tables — no exceptions
- Never use `service_role` key in client-side code or exposed API routes
- All DB queries from the app must go through parameterized queries or the typed Supabase client
- Index foreign keys and columns used in WHERE clauses (performance + prevents full-table scans exposing timing attacks)
- Audit log sensitive operations (user deletion, role changes, payment events) using a `_audit_log` table or PostgreSQL triggers

---

### Environment & Secrets

| Rule | Detail |
|---|---|
| `.env` never committed | Always in `.gitignore` — no exceptions |
| `.env.example` required | Checked in — shows all keys, no real values |
| Secrets rotation | Rotate immediately if a key is ever exposed in git history |
| Supabase anon key | Client-safe — but RLS must be enabled to protect data |
| Supabase service_role key | Server-only, never exposed to browser or client bundles |
| Vercel env vars | Set in Vercel dashboard — never in `vercel.json` |

---

## Vulnerability Report Template

```markdown
## Security Review — [Project Name] — [Date]

### Summary
[1-2 sentence overview of findings]

### Critical Issues (fix before deploy)
| # | File | Line | Issue | Fix |
|---|------|------|-------|-----|
| 1 | auth/login.ts | 42 | Plaintext password comparison | Use bcrypt.compare() |

### High Issues (fix this sprint)
| # | File | Line | Issue | Fix |
|---|------|------|-------|-----|

### Medium Issues (fix next sprint)
| # | File | Line | Issue | Fix |
|---|------|------|-------|-----|

### Passed Checks
- [x] npm audit — no HIGH/CRITICAL
- [x] No hardcoded secrets
- [x] RLS enabled on all tables
- [x] Auth required on all write routes
- [x] Zod validation on all API inputs

### Remediation Sign-off
Reviewed by: agent `security-auditor`
Re-reviewed after fixes: [ ]
```

---

## PR Review Checklist

Before approving any PR touching auth, data, or APIs:

```
[ ] No secrets or tokens in diff
[ ] All new API routes require authentication
[ ] User input validated before use
[ ] SQL uses parameterized queries / typed Supabase client
[ ] No dangerouslySetInnerHTML added
[ ] No new CORS wildcards
[ ] RLS policies cover new tables
[ ] .env.example updated if new env vars added
[ ] npm audit passes at high/critical level
```

---

## When to Load This Skill

- Writing or reviewing any auth flow (login, signup, OAuth, JWT)
- Adding a new API endpoint that accepts user input
- Integrating a third-party API with an API key
- Deploying to Vercel (pre-deploy sweep)
- After any dependency update that touches auth or crypto packages
- Any time `security-auditor` agent flags a finding that needs elaboration
