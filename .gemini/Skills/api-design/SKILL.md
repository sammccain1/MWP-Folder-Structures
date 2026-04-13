---
name: api-design
description: Guidelines and patterns for designing REST APIs from scratch. Use this when defining endpoints, OpenAPI contracts, or architecting API routing before implementation.
---

# API Design Skill

This skill enforces best practices for RESTful API design.

## When to Load
- Designing a new API service
- Writing `api-endpoint-template.md` definitions
- Refactoring inconsistent JSON responses
- Structuring route parameters vs query strings

## Core Principles

1. **Nouns, not verbs in URLs.** Use `/users` not `/getUsers`. Let HTTP methods (GET, POST, PUT, DELETE) dictate the action.
2. **Pluralized collections.** Always use `/users/:id` rather than `/user/:id`.
3. **Consistent Error Shape.** All errors must follow identical JSON structures. Use standard HTTP status codes.
4. **Versioning.** Put the API version in the URL path (e.g. `api/v1/resource`) or header, never assume it's unversioned.

## Implementation Patterns

### Standard JSON Wrapper
All API responses must wrap data in a top-level key to allow for future metadata (like pagination).

```json
// ✅ DO:
{
  "success": true,
  "data": { "id": 1, "name": "..." },
  "meta": {}
}

// ❌ DON'T:
{
  "id": 1,
  "name": "..."
}
```

### Consistent Errors
Errors should always have an `error` key containing a `code` and `message`.

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "The email field is required."
  }
}
```

### Pagination
Always use `limit` and `cursor` (or `offset`) for lists. Return pagination details inside `meta`.

```json
{
  "success": true,
  "data": [ ... ],
  "meta": {
    "next_cursor": "abc123_",
    "has_more": true
  }
}
```

## Verification
- Is the URL noun-based and pluralized?
- Does the response wrap data in `"data": {}`?
- Are error responses handled uniformly?
