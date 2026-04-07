# API Rules

Stack: FastAPI (Python) + Next.js API Routes / Server Actions (TypeScript)

---

## FastAPI — Route Structure

```python
# ✅ Full correct pattern — auth, typed input, typed output, service delegation
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from src.db import get_db
from src.auth import require_auth
from src.schemas import UserCreateRequest, UserResponse
from src.services import user_service

router = APIRouter(prefix="/users", tags=["users"])

@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    payload: UserCreateRequest,       # ✅ Pydantic model — validates at boundary
    db: AsyncSession = Depends(get_db),
    current_user = Depends(require_auth),  # ✅ Auth injected, not read manually
) -> UserResponse:
    return await user_service.create(db, payload)

# ❌ Anti-patterns in one place
@router.post("/users")
def create_user(payload: dict):          # no response_model, sync, raw dict
    db = SessionLocal()                  # leaks session
    user = User(**payload)               # no validation
    db.add(user); db.commit()
    return user
```

---

## FastAPI — Error Handling

```python
# ✅ Global exception handler — catches everything not already handled
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

app = FastAPI()

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    # Log with request context — never expose internal message to client
    logger.error("Unhandled error on %s %s: %s", request.method, request.url, exc, exc_info=True)
    return JSONResponse(status_code=500, content={"error": "Internal server error"})

# ✅ Expected errors — use HTTPException with specific status codes
@router.get("/{user_id}", response_model=UserResponse)
async def get_user(user_id: str, db: AsyncSession = Depends(get_db)):
    user = await user_service.get(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail=f"User {user_id} not found")
    return user
```

---

## FastAPI — Rate Limiting

```python
# Using slowapi (pip install slowapi)
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# ✅ Apply to sensitive endpoints
@router.post("/auth/login")
@limiter.limit("5/minute")    # 5 attempts per minute per IP
async def login(request: Request, payload: LoginRequest):
    ...

@router.post("/auth/forgot-password")
@limiter.limit("3/hour")
async def forgot_password(request: Request, payload: ForgotPasswordRequest):
    ...
```

---

## FastAPI — External HTTP Calls (with Timeout)

```python
import httpx

# ✅ Always set a timeout — never allow infinite hang
async def fetch_kenpom_data(year: int) -> dict:
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            response = await client.get(
                f"https://api.example.com/kenpom/{year}",
                headers={"Authorization": f"Bearer {settings.KENPOM_API_KEY}"},
            )
            response.raise_for_status()
            return response.json()
        except httpx.TimeoutException:
            raise HTTPException(status_code=504, detail="Upstream API timed out")
        except httpx.HTTPStatusError as e:
            raise HTTPException(status_code=502, detail=f"Upstream error: {e.response.status_code}")
```

---

## FastAPI — CORS

```python
from fastapi.middleware.cors import CORSMiddleware

# ✅ Explicit origins — never wildcard in production
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://your-app.vercel.app",
        "http://localhost:3000",     # dev only
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
)

# ❌ Never do this in production
app.add_middleware(CORSMiddleware, allow_origins=["*"])
```

---

## Next.js — Route Handlers (App Router)

```typescript
// app/api/results/[year]/route.ts
import { NextResponse } from 'next/server'
import { getServerSession } from 'next-auth'
import { authOptions } from '@/lib/auth'
import { ElectionResultSchema } from '@/lib/schemas'

export async function GET(
  req: Request,
  { params }: { params: { year: string } }
) {
  // ✅ Auth first — always
  const session = await getServerSession(authOptions)
  if (!session) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })

  // ✅ Validate params
  const year = parseInt(params.year)
  if (isNaN(year) || year < 2000 || year > 2100) {
    return NextResponse.json({ error: 'Invalid year' }, { status: 400 })
  }

  try {
    const data = await fetchElectionResults(year)
    return NextResponse.json(data)
  } catch (err) {
    console.error('[GET /api/results]', err)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

export async function POST(req: Request) {
  const session = await getServerSession(authOptions)
  if (!session) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })

  // ✅ Validate body with Zod
  const body = await req.json()
  const parsed = ElectionResultSchema.safeParse(body)
  if (!parsed.success) {
    return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 })
  }

  try {
    const result = await saveResult(parsed.data)
    return NextResponse.json(result, { status: 201 })
  } catch (err) {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
```

---

## Next.js — Server Actions

```typescript
// app/actions/results.ts
'use server'

import { revalidatePath } from 'next/cache'
import { getServerSession } from 'next-auth'
import { z } from 'zod'

const UpdateSchema = z.object({
  countyFips: z.string().length(5),
  demVotes: z.number().int().nonnegative(),
  repVotes: z.number().int().nonnegative(),
})

export async function updateCountyResult(formData: FormData) {
  const session = await getServerSession()
  if (!session) throw new Error('Unauthorized')   // ✅ Always auth-check in Server Actions

  const parsed = UpdateSchema.safeParse({
    countyFips: formData.get('countyFips'),
    demVotes: Number(formData.get('demVotes')),
    repVotes: Number(formData.get('repVotes')),
  })
  if (!parsed.success) throw new Error('Invalid input')

  await db.results.update({ where: { fips: parsed.data.countyFips }, data: parsed.data })
  revalidatePath('/results')  // ✅ Always revalidate after mutation
}
```

---

## Cross-Cutting Rules

| Rule | Detail |
|---|---|
| Always set timeouts | External HTTP calls: max 10s. DB queries: set statement timeout in connection config. |
| Rate limit auth endpoints | Login, signup, password reset: ≤5 req/min per IP |
| Never log request bodies | May contain PII, passwords, or tokens — log request IDs instead |
| Versioned endpoints | `/api/v1/...` — never break an existing route; bump version instead |
| Explicit response models | Every FastAPI route has a `response_model` — no naked `dict` returns |
| Auth is always first | Auth check before any DB access or computation in every route/action |