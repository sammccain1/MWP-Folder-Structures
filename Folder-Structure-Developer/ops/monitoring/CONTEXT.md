# ops/monitoring/ — Observability & Alerting

You are in the **monitoring directory**. All logging configuration, alerting rules, and observability setup live here.

## What Belongs Here

- **Structured logging configs** — JSON log formatters, log level settings, output destinations
- **Alerting rules** — Datadog monitors, PagerDuty policies, Prometheus alert rules (`*.yaml`)
- **Observability setup** — OpenTelemetry collector configs, tracing instrumentation hints
- **Dashboard definitions** — Grafana dashboard JSON exports, Datadog dashboard configs
- **Uptime checks** — Healthcheck endpoint definitions, synthetic monitor configs

## What Does NOT Belong Here

- Application-level logging calls — those go in `src/services/`
- Production secrets (Datadog API keys, PagerDuty tokens) — use `.env` + environment injection
- Test stubs or mock log outputs — those go in `src/tests/`

## Naming Convention

```
snake_case for config files
kebab-case for shell scripts

Examples:
  log_config.json
  prometheus-alerts.yaml
  datadog-dashboard.json
  healthcheck.sh
```

## Rules

- All configs must be version-controlled here — no manual UI-only changes in prod
- Never hardcode service URLs or credentials — use environment variables
- Alert thresholds should be commented with the reasoning (e.g., `# P99 > 2s triggers page`)
- Prometheus/Grafana setups: pin image versions in `ops/deploy/docker-compose.yml`
