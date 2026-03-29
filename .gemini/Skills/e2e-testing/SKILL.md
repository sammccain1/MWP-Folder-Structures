---
name: e2e-testing
description: Playwright and Agent Browser E2E test patterns. Load when writing, debugging, or maintaining E2E tests for Next.js apps. Provides Page Object Model templates, CI/CD config, selector strategy, and flaky test remediation patterns.
---

# E2E Testing Skill

Detailed Playwright patterns, Page Object Model examples, CI workflows, and artifact strategies for the `e2e-test-writer` agent.

---

## Project Setup

```bash
# Install Playwright
npm install -D @playwright/test
npx playwright install chromium  # or --with-deps for CI

# playwright.config.ts scaffold
```

```typescript
// playwright.config.ts
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./src/tests/e2e",
  timeout: 30_000,
  retries: process.env.CI ? 2 : 0,
  reporter: process.env.CI
    ? [["junit", { outputFile: "test-results/junit.xml" }], ["html"]]
    : "html",
  use: {
    baseURL: process.env.E2E_BASE_URL ?? "http://localhost:3000",
    screenshot: "only-on-failure",
    video: "on-first-retry",
    trace: "on-first-retry",
  },
  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
  ],
  webServer: {
    command: "npm run dev",
    url: "http://localhost:3000",
    reuseExistingServer: !process.env.CI,
  },
});
```

---

## Page Object Model Template

```typescript
// src/tests/e2e/pages/LoginPage.ts
import { Page, Locator, expect } from "@playwright/test";

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.getByTestId("email-input");
    this.passwordInput = page.getByTestId("password-input");
    this.submitButton = page.getByRole("button", { name: /sign in/i });
    this.errorMessage = page.getByTestId("auth-error");
  }

  async goto() {
    await this.page.goto("/login");
    await expect(this.submitButton).toBeVisible();
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async expectError(message: string) {
    await expect(this.errorMessage).toContainText(message);
  }
}
```

---

## Test Templates by Journey Type

### Auth Flow

```typescript
// src/tests/e2e/auth.spec.ts
import { test, expect } from "@playwright/test";
import { LoginPage } from "./pages/LoginPage";

test.describe("Authentication", () => {
  test("user can sign in with valid credentials", async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login(
      process.env.E2E_TEST_EMAIL!,
      process.env.E2E_TEST_PASSWORD!
    );
    await expect(page).toHaveURL("/dashboard");
    await expect(page.getByTestId("user-menu")).toBeVisible();
  });

  test("shows error for invalid credentials", async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login("wrong@email.com", "wrongpassword");
    await loginPage.expectError("Invalid credentials");
  });
});
```

### API / Data Flow

```typescript
test("bracket simulation returns results", async ({ page, request }) => {
  // API test alongside UI
  const response = await request.post("/api/simulate", {
    data: { iterations: 10 },
  });
  expect(response.ok()).toBeTruthy();
  const body = await response.json();
  expect(body.champion).toBeDefined();
});
```

---

## Selector Strategy (Priority Order)

```typescript
// 1. By role (most resilient — works with accessibility)
page.getByRole("button", { name: "Submit" })

// 2. By test ID (explicit contract — add data-testid to components)
page.getByTestId("submit-button")

// 3. By label (good for form inputs)
page.getByLabel("Email address")

// 4. By text (caution — brittle if copy changes)
page.getByText("Welcome back")

// ❌ Last resort only — brittle, breaks on refactor
page.locator(".my-class > div:nth-child(2)")
```

**Rule:** Every interactive element in a React component should have a `data-testid`. Add them during development, not during test writing.

---

## Flaky Test Remediation

```typescript
// ❌ Time-based wait — flaky
await page.waitForTimeout(2000);

// ✅ Condition-based wait — resilient
await page.waitForResponse(resp => resp.url().includes("/api/data") && resp.ok());
await expect(page.getByTestId("results-list")).toBeVisible();
await page.waitForLoadState("networkidle");

// Quarantine a flaky test (add issue reference)
test.fixme("flaky: leaderboard polling", async ({ page }) => {
  // Tracked in: https://github.com/sammccain1/repo/issues/42
});

// Run a test 10x to detect flakiness
// npx playwright test --repeat-each=10 tests/leaderboard.spec.ts
```

---

## GitHub Actions CI Template

```yaml
# .github/workflows/e2e.yml
name: E2E Tests

on:
  push:
    branches: [main]
  pull_request:

jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: "20" }
      - run: npm ci
      - run: npx playwright install chromium --with-deps

      - name: Run E2E tests
        run: npx playwright test
        env:
          E2E_BASE_URL: ${{ secrets.E2E_BASE_URL }}
          E2E_TEST_EMAIL: ${{ secrets.E2E_TEST_EMAIL }}
          E2E_TEST_PASSWORD: ${{ secrets.E2E_TEST_PASSWORD }}

      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 14
```

---

## Critical Journeys to Cover (Every Project)

| Priority | Journey | Why |
|---|---|---|
| CRITICAL | Sign up / Sign in / Sign out | Auth is the gate to everything |
| CRITICAL | Core feature happy path | The thing the app actually does |
| HIGH | Form submission + validation | Most common source of UX bugs |
| HIGH | Error state / 404 / empty state | Often forgotten, always hit |
| MEDIUM | Navigation + routing | Broken links erode trust |
| MEDIUM | Mobile viewport | If the app is responsive |
| LOW | Logged-out vs. logged-in views | Auth-protected vs. public routes |
