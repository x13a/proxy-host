#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${ENV_FILE:-./cloudflare.env}"

set_ech() {
    local value="${1:-off}"
    [ -f "$ENV_FILE" ] && source "$ENV_FILE"
    curl -sS \
        -X PATCH "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/settings/ech" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"id\":\"ech\",\"value\":\"$value\"}"
}

set_ech "$@"
