---
name: pen-test
description: Run a structured penetration test against a local or staging application. Executes recon, OWASP Top 10 checks, and produces a findings report. Use before delivering any client web application.
allowed_tools: ["Bash", "Read", "Write"]
---

# /pen-test

Run a structured security assessment before delivering any client web application or entering a hackathon that scores on security.

---

## Required Inputs

| Input | Example |
|---|---|
| `TARGET_URL` | `http://localhost:3000` (local) or `https://staging.client.com` (staging) |
| `API_URL` | `http://localhost:8000` or `https://api.staging.client.com` |
| `SCOPE` | Routes, endpoints, or features to test |

> ⚠️ Only run against environments you own or have explicit written permission to test.

---

## Step 1 — Environment Check

```bash
# Verify target is reachable
curl -I "$TARGET_URL"
curl -I "$API_URL/docs"

# Check installed tools
for tool in nmap nikto sqlmap ffuf pa11y; do
  command -v "$tool" &>/dev/null && echo "✅ $tool" || echo "❌ $tool (not installed)"
done
```

Install missing tools:
```bash
brew install nmap nikto sqlmap ffuf
npm install -g pa11y
```

---

## Step 2 — Automated Scans

```bash
# Port scan (local only — do NOT run against production)
nmap -sV -p 80,443,3000,8000,5432,6379 localhost

# Web server vulnerability scan
nikto -h "$TARGET_URL" -output "docs/security/nikto-$(date +%Y-%m-%d).txt"

# Directory/endpoint fuzzing
ffuf -u "$API_URL/FUZZ" \
  -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt \
  -mc 200,201,301,302 \
  -o "docs/security/ffuf-$(date +%Y-%m-%d).json"
```

---

## Step 3 — Manual OWASP Top 10 Checks

Work through the **pen-testing skill** (`/skills pen-testing`) for:

- [ ] A01: Access control — test accessing other users' resources with your own token
- [ ] A02: Crypto — verify HTTPS, password hashing, JWT expiry
- [ ] A03: Injection — SQLi in search/filter params, XSS in text inputs
- [ ] A05: Misconfiguration — check CSP, CORS, X-Frame-Options headers
- [ ] A07: Auth failures — rate limiting on login, session invalidation on logout
- [ ] A09: Logging — verify failed logins and 403s are logged

---

## Step 4 — Accessibility Check

```bash
# Run WCAG2AA check (separate from security, but required for client delivery)
pa11y "$TARGET_URL" --standard WCAG2AA --reporter cli
```

---

## Step 5 — Produce Security Report

Create `docs/security/YYYY-MM-DD_security-report.md` using the template in the `pen-testing` skill.

For each finding:
1. Assign severity: `Critical / High / Medium / Low / Informational`
2. Document reproduction steps
3. Recommend a specific fix
4. Mark status: `Open / Fixed / Accepted Risk`

---

## Step 6 — Verify Fixes

After the dev team addresses findings:

```bash
# Re-run automated scans to confirm closure
nikto -h "$TARGET_URL"
bash .gemini/hooks/secrets-check.sh
bash .gemini/hooks/dependency-check.sh
```

Update each finding's status in the report before client delivery.

---

## Notes

- Always test on staging before moving to production scopes
- Never run `sqlmap` against a production database — data loss risk
- Keep all scan output files in `docs/security/` — gitignored by default (add to `.gitignore` if needed)
- For client engagements: attach the security report as a deliverable in `Client-*/Deliverables/`
