#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="./caddy.env"

gen_secret() {
    openssl rand -hex 8
}

set_env() {
    local key="$1"
    local value="$2"
    sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
}

main() {
    local path_vars secret
    path_vars=$(grep -Eo '^[A-Z0-9_]+_PATH=' "$ENV_FILE" | sed 's/=$//')
    for var in $path_vars; do
        secret="/$(gen_secret)"
        set_env "$var" "$secret"
    done
    secret="$(gen_secret)$(gen_secret)"
    set_env "CDN_AUTH_TOKEN" "$secret"
    echo "done"
}

main
