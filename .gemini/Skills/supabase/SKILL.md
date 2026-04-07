---
name: supabase
description: Supabase-specific patterns for auth, RLS, Edge Functions, Storage, Realtime, and local dev. Load when integrating Supabase into any project — auth flows, database policies, file uploads, or live data subscriptions.
---

# Supabase Skill

Patterns, code examples, and rules for Sam's Supabase usage across FastAPI and Next.js projects.

---

## Local Development

```bash
# Start local Supabase stack (Docker required)
supabase start

# Output includes:
#   API URL:     http://localhost:54321
#   DB URL:      postgresql://postgres:postgres@localhost:54322/postgres
#   Studio URL:  http://localhost:54323
#   anon key:    eyJ...  (safe for client use)
#   service_role key: eyJ...  (SERVER ONLY — never expose)

# Apply migrations to local
supabase db push

# Reset local DB to clean state
supabase db reset

# Stop stack
supabase stop
```

**Rule:** Always develop against `supabase start` locally — never against the production project.

---

## Auth Patterns

### Next.js (App Router)

```typescript
// lib/supabase/server.ts — server-side client (cookies)
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export function createClient() {
  const cookieStore = cookies()
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name) { return cookieStore.get(name)?.value },
        set(name, value, options) { cookieStore.set({ name, value, ...options }) },
        remove(name, options) { cookieStore.set({ name, value: '', ...options }) },
      },
    }
  )
}

// app/api/protected/route.ts — protect an API route
import { createClient } from '@/lib/supabase/server'

export async function GET() {
  const supabase = createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return new Response('Unauthorized', { status: 401 })
  // proceed
}
```

### FastAPI (Python)

```python
# Verify Supabase JWT in FastAPI
import os
from jose import jwt, JWTError
from fastapi import Depends, HTTPException, Header

SUPABASE_JWT_SECRET = os.getenv("SUPABASE_JWT_SECRET")

def get_current_user(authorization: str = Header(...)):
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid auth header")
    token = authorization[7:]
    try:
        payload = jwt.decode(token, SUPABASE_JWT_SECRET, algorithms=["HS256"],
                             audience="authenticated")
        return payload
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
```

---

## Row Level Security (RLS)

```sql
-- ALWAYS enable RLS on every table that stores user data
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Users can only read their own posts
CREATE POLICY "read_own_posts"
  ON posts FOR SELECT
  USING (auth.uid() = user_id);

-- Users can only insert their own posts
CREATE POLICY "insert_own_posts"
  ON posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can only update their own posts
CREATE POLICY "update_own_posts"
  ON posts FOR UPDATE
  USING (auth.uid() = user_id);

-- Service role bypass (for admin ops only — never expose service_role client-side)
-- No policy needed: service_role bypasses RLS by default
```

**Rules:**
- Enable RLS on every table — no exceptions
- `anon` key is client-safe only IF RLS is enabled
- `service_role` key is server-only — never in client bundles or exposed API routes
- Use `auth.uid()` as the primary ownership check

---

## Edge Functions

```typescript
// supabase/functions/send-email/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { email, message } = await req.json()

  // Access secrets via Deno.env (set via: supabase secrets set KEY=value)
  const apiKey = Deno.env.get("RESEND_API_KEY")

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: "noreply@example.com", to: email, subject: "Hi", html: message }),
  })

  return new Response(JSON.stringify({ success: res.ok }), {
    headers: { "Content-Type": "application/json" },
  })
})
```

```bash
# Deploy function
supabase functions deploy send-email

# Set secrets (never hardcode)
supabase secrets set RESEND_API_KEY=re_abc123
```

---

## Storage

```typescript
// Upload a file
const { data, error } = await supabase.storage
  .from('avatars')
  .upload(`${user.id}/avatar.png`, file, { upsert: true })

// Get a public URL
const { data: { publicUrl } } = supabase.storage
  .from('avatars')
  .getPublicUrl(`${user.id}/avatar.png`)

// Storage RLS — set in Supabase dashboard or via migrations
// Example: users can only manage their own avatar folder
```

**Rules:**
- Never use the service_role key to bypass storage RLS in client-facing code
- Use `upsert: true` for avatar/profile uploads to avoid duplicate errors
- Set storage bucket policies to match your DB RLS policies

---

## Realtime

```typescript
// Subscribe to row-level changes
const channel = supabase
  .channel('scores')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'game_scores' },
    (payload) => console.log('New score:', payload.new)
  )
  .subscribe()

// Cleanup on unmount
return () => supabase.removeChannel(channel)
```

---

## Environment Variables

| Variable | Where | Notes |
|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | Client + Server | Safe to expose |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Client + Server | Safe only with RLS enabled |
| `SUPABASE_SERVICE_ROLE_KEY` | Server only | Never in client bundles |
| `SUPABASE_JWT_SECRET` | FastAPI backend | For manual JWT verification |

---

## When to Load This Skill

- Setting up auth (login, signup, OAuth, magic link)
- Writing or reviewing RLS policies
- Creating Edge Functions
- Integrating file uploads with Storage
- Adding Realtime subscriptions to a Next.js component
- Running `supabase start` for local dev setup
