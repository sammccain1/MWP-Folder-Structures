# API Rules

Stack: FastAPI (Python) + Next.js API Routes (TypeScript)

## FastAPI

- All routes must have explicit `response_model` typed returns
- Use `Depends()` for auth injection — never read headers manually in route handlers
- Validate all inputs with Pydantic models at the boundary — never trust raw dicts
- `HTTPException` for expected errors; let unhandled exceptions propagate to the global handler
- Async routes (`async def`) for any I/O — DB calls, external HTTP, file reads
- No business logic in route handlers — delegate to `src/services/`

```python
# ✅ Correct pattern
@router.post("/users", response_model=UserResponse)
async def create_user(
    payload: UserCreateRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_auth),
) -> UserResponse:
    return await user_service.create(db, payload)

# ❌ Anti-pattern — logic in route, no response_model, raw dict input
@router.post("/users")
def create_user(payload: dict):
    db = SessionLocal()
    user = User(**payload)
    db.add(user)
    db.commit()
    return user
```

## Next.js API Routes

- Use `NextResponse.json()` for all responses — never `res.json()` (Pages Router pattern)
- Auth check is always first: `const session = await getServerSession(); if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 })`
- Validate request body with Zod before using it
- Wrap handler body in `try/catch` — return `{ error: message }` with appropriate status on catch

```typescript
// ✅ Correct pattern
export async function POST(req: Request) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const body = await req.json();
  const parsed = CreateUserSchema.safeParse(body);
  if (!parsed.success) return NextResponse.json({ error: parsed.error }, { status: 400 });

  try {
    const user = await userService.create(parsed.data);
    return NextResponse.json(user, { status: 201 });
  } catch (err) {
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
```

## Cross-Cutting

- All external API calls must have a timeout set
- Rate limit sensitive endpoints (auth, password reset)
- Log request ID on errors — never log request body (may contain PII)
- Versioned endpoints: `/api/v1/...` — never break an existing route without a version bump