# Flare Incident Scope

On-demand audit log analysis for security incidents. Pulls cloud audit logs for a time window, runs AI-powered analysis, and creates a GitHub Issue with a correlated timeline narrative.

## Quick start

```yaml
# .github/workflows/incident-scope.yml
name: Incident Scope
on:
  workflow_dispatch:
    inputs:
      time_from:
        description: 'Start of incident window (ISO 8601)'
        required: true
      time_to:
        description: 'End of incident window (ISO 8601, default: now)'
        required: false
        default: ''

jobs:
  scope:
    runs-on: ubuntu-latest
    permissions:
      issues: write
    steps:
      - uses: tryflare-ai/incident-scope@v1
        with:
          token: ${{ secrets.FLARE_API_KEY }}
          time-from: ${{ inputs.time_from }}
          time-to: ${{ inputs.time_to }}
```

## Setup

1. Sign up at [tryflare.ai](https://tryflare.ai)
2. Connect your GCP project (OAuth, 60 seconds)
3. Go to **Settings > API Keys** and create a key
4. Add the key as a repository secret named `FLARE_API_KEY`
5. Add the workflow above to `.github/workflows/incident-scope.yml`

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `token` | Yes | -- | Flare API key (`flr_pr_...`). Generate from the Connectors page at tryflare.ai. |
| `time-from` | Yes | -- | Start of incident window (ISO 8601). |
| `time-to` | No | now | End of incident window (ISO 8601). |
| `connector-id` | No | most recent | Flare connector ID. If omitted, uses most recently created active connector. |
| `severity-filter` | No | `all` | Minimum severity floor: `all`, `medium`, `high`, `critical`. |
| `api-url` | No | `https://www.tryflare.ai/api/webhooks/incident-scope` | Override for self-hosted. |

## Outputs

| Output | Description |
|--------|-------------|
| `issue-url` | URL of the created GitHub Issue. |
| `total-events` | Total audit log events analyzed. |
| `truncated` | Whether logs were capped due to volume (`true`/`false`). |

## What it creates

A GitHub Issue with:

- **Narrative** -- AI-synthesized plain-English summary of what happened during the incident window
- **Timeline table** -- chronological events with service, actor, action, and severity
- **Severity counts** -- critical, high, medium findings at a glance

## What Flare detects

The incident analysis focuses on:

- **Timeline reconstruction** -- cross-service event ordering
- **Lateral movement** -- when one action enables access in a different service
- **Privilege escalation** -- self-grants, IAM policy changes, service account key creation
- **Data access patterns** -- who accessed what data stores and when
- **Permission failure clusters** -- PERMISSION_DENIED spikes that suggest reconnaissance

## Limits

- Maximum time window: 24 hours
- Maximum events: 5,000 (severity-prioritized truncation if exceeded)
- Daily limit: 10 analyses/day (shared across all Flare features)
- Latency: under 90 seconds for windows under 4 hours

## Requirements

- A Flare account with a connected GCP connector ([sign up](https://tryflare.ai/sign-up))
- `jq` and `curl` available on the runner (included in `ubuntu-latest`)
- Repository permission: `issues: write`

## Learn more

- [GCP Audit Log anomaly detection](https://tryflare.ai/gcp-audit-log-anomaly-detection)
- [Flare documentation](https://docs.tryflare.ai)

## License

MIT
