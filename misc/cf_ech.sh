#!/usr/bin/env bash
set -euo pipefail

curl \
    -X PATCH "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/settings/ech" \
    -H "X-Auth-Key: ${CF_GLOBAL_API_KEY}" \
    -H "X-Auth-Email: ${CF_EMAIL}" \
    -H "Content-Type: application/json" \
    --data '{"id":"ech","value":"off"}'
