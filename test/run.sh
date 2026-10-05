#!/usr/bin/env bash
# shellcheck disable=SC2016 # hostile strings are literal on purpose
# shellcheck source=test/lib.sh
# Smoke tests for action.yml. Usage: bash test/run.sh
. "$(dirname "$0")/lib.sh"

scope() { # scope <token> [VAR=value ...]
  local token=$1; shift
  run_step 0 FLARE_TOKEN="$token" FLARE_API_URL="$API/api/webhooks/incident-scope" \
    TIME_FROM_INPUT="$HOSTILE" TIME_TO_INPUT="${TIME_TO-}" CONNECTOR_ID="" SEVERITY_FILTER=all \
    REPO=o/r ACTOR='octo$(touch /tmp/flare-pwned)' "$@"
}

scope flr_pr_test_token
check "analysis exits 0" "$RC" 0
check "total_events output" "$(output total_events)" 42
check "issue_url output" "$(output issue_url)" https://github.com/o/r/issues/1
check "hostile time-from sent verbatim" \
  "$(last_request | "$PY" -c 'import json,sys; print(json.load(sys.stdin)["body"]["time_from"])')" "$HOSTILE"
check "time_to omitted when empty" \
  "$(last_request | "$PY" -c 'import json,sys; print("time_to" in json.load(sys.stdin)["body"])')" False
check "narrative kept literal" "$(grep -c '100% sure: %s %n' "$GH_BODY")" 1
check "timeline row rendered" "$(grep -c '^| t1 | iam | a@b | SetIamPolicy | critical |$' "$GH_BODY")" 1

TIME_TO='2026-10-05T01:00:00Z' scope flr_pr_test_token
check "time_to sent when set" \
  "$(last_request | "$PY" -c 'import json,sys; print(json.load(sys.stdin)["body"]["time_to"])')" 2026-10-05T01:00:00Z

scope ""
check "missing token fails" "$RC" 1

scope bad-token-0000
check "invalid token fails" "$RC" 1

scope limit-token-000
check "rate limit fails" "$RC" 1
check "rate limit message" "$(grep -c 'daily analysis limit' "$WORK/stdout")" 1

finish
