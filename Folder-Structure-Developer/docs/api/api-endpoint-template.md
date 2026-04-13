# API Endpoint: [Endpoint Name]

**Path:** `[GET|POST|PUT|DELETE] /api/v1/...`  
**Authentication required:** [Yes/No]

## Description
What does this endpoint do? Context regarding inputs and system impact.

## Request

**Headers:**
```json
{
  "Authorization": "Bearer <token>"
}
```

**Body:**
```json
{
  "field": "string"
}
```

## Response

**Success (200 OK):**
```json
{
  "data": {},
  "success": true
}
```

**Errors:**
- `400 Bad Request` — invalid inputs.
- `401 Unauthorized` — missing or invalid token.

## Implementation Link
*(Add the relative path to the source file here once built, e.g., `src/app/api/...`)*
