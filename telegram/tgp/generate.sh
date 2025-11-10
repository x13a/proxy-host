#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<EOF
Usage: $(basename "$0") HOST [PORT]

Generates:
  - hex secret for config (ee + 16 random bytes + hostname as hex)
  - tg://proxy url form

Arguments:
  HOST   domain hostname (required)
  PORT   tcp port (default: 443)
EOF
}

make_proxy_url() {
    local secret="$1"
    local host="$2"
    local port="$3"
    echo "tg://proxy?server=${host}&port=${port}&secret=${secret}"
}

gen_base64_secret() {
    local key="$1"
    local host="$2"
    {
        printf '\xee'
        printf '%s' "$key" | xxd -r -p
        printf '%s' "$host"
    } | base64 | tr '+/' '-_' | tr -d '='
}

gen_config_secret() {
    local key="$1"
    local host="$2"
    local host_hex
    [[ -z "$host" ]] && { echo "error: host is required, exit" >&2; exit 1; }
    host_hex="$(echo -n "$host" | xxd -p -c 256)"
    echo "ee${key}${host_hex}"
}

main() {
    if [[ "${1:-}" == "" ]]; then
        usage
        exit 1
    fi
    local host="$1"
    local port="${2:-443}"
    local key="$(openssl rand -hex 16)"
    local conf_secret="$(gen_config_secret "$key" "$host")"
    local base64_secret="$(gen_base64_secret "$key" "$host")"
    echo "[*] config secret: $conf_secret"
    echo "[*] proxy url:     $(make_proxy_url "$base64_secret" "$host" "$port")"
}

main "$@"
