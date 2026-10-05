# Flare Incident Scope

Investigate a cloud audit-log time window from GitHub. Flare returns an analysis with an event timeline and findings, then this Action creates a GitHub Issue for your team to review.

**Start here:** [Setup and all four Actions](https://tryflare.ai/github-actions) · [PR review demo](https://github.com/tryflare-ai/actions-demo)

Requires a Flare API key, a supported cloud connector, and `issues: write`. Review the Issue's audience before posting cloud activity to a public repository.

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
          api-url: https://tryflare.ai/api/webhooks/incident-scope
          time-from: ${{ inputs.time_from }}
          time-to: ${{ inputs.time_to }}
```

## Setup

1. Sign up at [tryflare.ai](https://tryflare.ai)
2. Connect your GCP project using OAuth
3. Go to **Settings > API Keys** and create a key
4. Add the key as a repository secret named `FLARE_API_KEY`
5. Add the workflow above to `.github/workflows/incident-scope.yml`

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `token` | Yes | -- | Flare API key (`flr_pr_...`). Generate under Settings → API Keys at tryflare.ai. |
| `time-from` | Yes | -- | Start of incident window (ISO 8601). |
| `time-to` | No | now | End of incident window (ISO 8601). |
| `connector-id` | No | most recent | Flare connector ID. If omitted, uses most recently created active connector. |
| `severity-filter` | No | `all` | Minimum severity floor: `all`, `medium`, `high`, `critical`. |
| `api-url` | No | `https://tryflare.ai/api/webhooks/incident-scope` | Override for self-hosted. |

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
- Latency depends on log volume and service availability; no fixed completion time is guaranteed

## Requirements

- A Flare account with a connected GCP connector ([sign up](https://tryflare.ai/sign-up))
- `jq` and `curl` available on the runner (included in `ubuntu-latest`)
- Repository permission: `issues: write`

## Learn more

- [GCP Audit Log anomaly detection](https://tryflare.ai/gcp-audit-log-anomaly-detection)
- [Flare documentation](https://docs.tryflare.ai)

## License

MIT

## Data handling and limits

The Action sends the requested window and repository metadata to Flare. Flare reads audit logs through your connector and uses its AI provider for analysis. The resulting GitHub Issue may include actors, resources and supporting event details. Repository visibility determines who can read it.

Maximum incident window: 24 hours. Incident analysis shares the hosted daily analysis allowance. Check output truncation and coverage before drawing conclusions.

The Action code is MIT-licensed; hosted analysis requires a Flare account and is subject to [current service terms](https://tryflare.ai/#pricing). AI findings are review assistance, not proof of compromise or a guarantee that an environment is secure. [Privacy policy](https://tryflare.ai/privacy).

## More Flare Actions

[PR security check](https://github.com/tryflare-ai/pr-security-check) · [Deploy review](https://github.com/tryflare-ai/deploy-webhook) · [Incident scope](https://github.com/tryflare-ai/incident-scope) · [Security changelog](https://github.com/tryflare-ai/security-changelog)
