---
name: pen-testing
description: Penetration testing and security assessment patterns for full-stack web applications. Load when performing security reviews, discovering vulnerabilities, or hardening a client application before delivery. Covers OWASP Top 10, common attack vectors for Next.js + FastAPI stacks, and responsible disclosure practices.
---

# Pen Testing Skill

Structured security assessment for full-stack web applications. Scoped to the Next.js App Router + FastAPI stack. Use this for client pre-delivery hardening and hackathon "security" category wins.

> **Ethics:** Only test applications you own or have explicit written permission to test. Unauthorized penetration testing is illegal.

---

## Recon Phase

Before touching anything, gather intel:

```bash
# Enumerate tech stack from headers
curl -I https://target.example.com | grep -E "Server:|X-Powered-By:|X-Frame-Options:|Content-Security-Policy:"

# Check for exposed robots.txt and sitemap
curl https://target.example.com/robots.txt
curl https://target.example.com/sitemap.xml

# Look for common exposed admin routes
for path in /admin /dashboard /api/docs /api/v1/docs /.env /.env.local /graphql; do
  echo -n "$path: "; curl -s -o /dev/null -w "%{http_code}" "https://target.example.com$path"; echo
done
```

---

## OWASP Top 10 — Checklist for Full-Stack Apps

### A01: Broken Access Control
```bash
# Test horizontal privilege escalation: access another user's resource
# Normal user token
TOKEN_USER_A="eyJ..."

# Try accessing User B's resource with User A's token
curl -H "Authorization: Bearer $TOKEN_USER_A" https://api.example.com/users/user-b-uuid/data
# Expect: 403 Forbidden. If 200 → VULNERABLE
```

**Check in code:**
- Every API route validates `session.user.id === resource.ownerId`
- No resource IDs exposed sequentially (use UUIDs, not `/users/1`)
- Admin routes protected by role check, not just authentication

---

### A02: Cryptographic Failures
- [ ] HTTPS enforced everywhere — no HTTP fallback
- [ ] No sensitive data in URL params (tokens, IDs in query strings)
- [ ] JWTs use `HS256` minimum — verify `alg` header cannot be set to `none`
- [ ] Passwords hashed with `bcrypt` (cost ≥ 12) or `argon2`

```python
# ✅ Safe FastAPI password flow
from passlib.context import CryptContext
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto", bcrypt__rounds=12)

hashed = pwd_context.hash(plain_password)
verified = pwd_context.verify(plain_password, hashed)
```

---

### A03: Injection

**SQL Injection test:**
```bash
# Try basic SQLi in query params
curl "https://api.example.com/search?q='; DROP TABLE users;--"
curl "https://api.example.com/search?q=1 OR 1=1"
# A 500 error or unexpected data → investigate
```

**XSS test:**
```javascript
// Paste this into any user-controlled text input field
<script>alert('XSS')</script>
<img src=x onerror="alert('XSS')">
// If a dialog appears → stored XSS vulnerability
```

**Next.js note:** React escapes output by default — XSS only possible via `dangerouslySetInnerHTML`. Grep for it:
```bash
grep -r "dangerouslySetInnerHTML" src/ --include="*.tsx" --include="*.jsx"
```

---

### A05: Security Misconfiguration

```bash
# Check CSP headers
curl -sI https://target.example.com | grep "Content-Security-Policy"
# Missing or overly broad (unsafe-inline, unsafe-eval) → flag

# Check CORS policy
curl -H "Origin: https://evil.example.com" \
     -H "Access-Control-Request-Method: GET" \
     -X OPTIONS https://api.example.com/v1/users -v 2>&1 | grep "Access-Control"
# If Access-Control-Allow-Origin: * on auth endpoints → VULNERABLE
```

**Next.js `next.config.ts` security headers:**
```typescript
const securityHeaders = [
  { key: 'X-DNS-Prefetch-Control', value: 'on' },
  { key: 'X-Frame-Options', value: 'SAMEORIGIN' },
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
  { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
  {
    key: 'Content-Security-Policy',
    value: [
      "default-src 'self'",
      "script-src 'self' 'unsafe-eval' 'unsafe-inline'",  // tighten after dev
      "style-src 'self' 'unsafe-inline'",
      "img-src 'self' data: https:",
      "connect-src 'self' https://api.example.com",
    ].join('; '),
  },
]
```

---

### A07: Identification and Authentication Failures

```bash
# Test rate limiting on login endpoint
for i in {1..20}; do
  curl -s -X POST https://api.example.com/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"test@example.com","password":"wrong"}' \
    -o /dev/null -w "%{http_code}\n"
done
# All 200 or 400? No 429? → No rate limiting → VULNERABLE
```

**Checklist:**
- [ ] Login endpoint rate-limited (max 5 attempts per 15 min per IP)
- [ ] Password reset tokens expire (≤ 1 hour) and are single-use
- [ ] JWT expiry set (e.g., `exp: 7d`) — no non-expiring tokens
- [ ] Sessions invalidated on logout (not just deleted client-side)

---

### A09: Security Logging and Monitoring Failures

Every application must log at minimum:
- Failed login attempts (with IP, timestamp, username)
- Access control failures (403s)
- Input validation failures on security-sensitive endpoints
- Admin actions

```python
# FastAPI audit log example
import logging
security_logger = logging.getLogger("security")

@router.post("/login")
async def login(payload: LoginRequest, request: Request):
    user = await auth_service.authenticate(payload.email, payload.password)
    if not user:
        security_logger.warning(
            "Failed login attempt",
            extra={"ip": request.client.host, "email": payload.email}
        )
        raise HTTPException(status_code=401, detail="Invalid credentials")
```

---

## Tools (All Free/Open Source)

| Tool | Purpose | Install |
|---|---|---|
| `nikto` | Web server scanner | `brew install nikto` |
| `sqlmap` | Automated SQLi detection | `brew install sqlmap` |
| `nmap` | Port/service enumeration | `brew install nmap` |
| `ffuf` | Directory/endpoint fuzzing | `brew install ffuf` |
| OWASP ZAP | Full GUI proxy + scanner | Download from owasp.org |
| Burp Suite Community | Manual proxy + repeater | Download from portswigger.net |

---

## Pre-Delivery Security Report Template

Save as `Client-*/Deliverables/YYYY-MM-DD_security-report.md`:

```markdown
# Security Assessment Report: [App Name]
**Date:** [YYYY-MM-DD]
**Tester:** Sam McCain
**Scope:** [URLs, endpoints assessed]

## Executive Summary
[2 sentences: overall risk posture and most critical finding]

## Findings

| ID | Title | Severity | OWASP | Status |
|---|---|---|---|---|
| F-01 | [Finding] | Critical/High/Med/Low | A01 | Fixed / Open |

## Finding Detail: F-01
**Severity:** Critical
**Description:** [What the vulnerability is]
**Evidence:** [Reproduction steps or screenshot]
**Impact:** [What an attacker could do]
**Remediation:** [Specific fix with code example]

## Remediation Status
[Track which findings were fixed before delivery]
```
