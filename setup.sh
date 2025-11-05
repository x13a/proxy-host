#!/usr/bin/env bash
set -eEuo pipefail
trap 'echo "err: $BASH_COMMAND on line $LINENO" >&2' ERR

BASE_DIR="$(dirname "$(realpath "$0")")"

declare -A VARS
declare -A DEFAULTS

VARS[domain]=""
VARS[panel_path]=""
DEFAULTS[panel]="3x-ui"

is_root() {
    [ "$(id -u)" -eq 0 ]
}

install_docker() {
    if command -v docker >/dev/null 2>&1; then
        echo "[*] docker already installed"
        return 0
    fi
    echo "[*] installing docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm -f ./get-docker.sh
    sudo groupadd -f docker
    sudo usermod -aG docker "$(whoami)"
    echo "[+] docker installed"
}

configure_sysctl() {
    local target="/etc/sysctl.d/proxy.conf"
    [[ -f "$BASE_DIR/$target" ]] || { echo "err: missing $target, exit" >&2; exit 1; }
    echo "[*] configuring sysctl..."
    sudo install -m 644 -o root -g root "$BASE_DIR/$target" "$target"
    echo "[+] sysctl config deployed to $target"
}

ask_domain() {
    local domain
    read -rp "Enter your domain: " domain
    [[ -z "$domain" ]] && { echo "err: domain cannot be empty, exit" >&2; exit 1; }
    VARS[domain]="$domain"
}

set_domain() {
    env_file="$BASE_DIR/caddy/caddy.env"
    [[ -f "$env_file" ]] || { echo "err: $env_file not found, exit" >&2; exit 1; }
    sed -i "s/^DOMAIN=.*/DOMAIN=${VARS[domain]}/" "$env_file"
    echo "[*] updated $env_file with domain ${VARS[domain]}"
}

set_caddy_env() {
    set_env_script="$BASE_DIR/caddy/set_env.sh"
    env_file="$BASE_DIR/caddy/caddy.env"
    [[ -f "$set_env_script" ]] || { echo "err: $set_env_script not found, exit" >&2; exit 1; }
    ENV_FILE="$env_file" bash "$set_env_script"
    echo "[*] executed $set_env_script with ENV_FILE=$env_file"
}

cp_compose_file() {
    src_file="$BASE_DIR/compose/3x-ui.yml"
    dst_file="$BASE_DIR/compose.yml"
    [[ -f "$src_file" ]] || { echo "err: $src_file not found" >&2; exit 1; }
    cp "$src_file" "$dst_file"
    echo "[*] copied $src_file to $dst_file"
}

install_sqlite() {
    if command -v sqlite3 >/dev/null 2>&1; then
        echo "[*] sqlite3 already installed"
        return 0
    fi
    echo "[*] installing sqlite3..."
    sudo apt-get update
    sudo apt-get install -y sqlite3
    echo "[+] sqlite3 installed"
}

init_panel_db() {
    local compose_file="$BASE_DIR/compose.yml"
    echo "[*] starting docker compose to initialize database..."
    docker compose -f "$compose_file" up -d
    echo "[*] waiting for 5 seconds for database initialization..."
    sleep 5
    docker compose -f "$compose_file" down
    echo "[*] docker compose stopped, database should be initialized"
}

set_panel_path() {
    local db_file="$BASE_DIR/3x-ui/db/x-ui.db"
    local env_file="$BASE_DIR/caddy/caddy.env"
    [[ -f "$db_file" ]] || { echo "err: $db_file not found, exit" >&2; exit 1; }
    local panel_path
    panel_path=$(grep -E '^PANEL_PATH=' "$env_file" | cut -d'=' -f2-)
    [[ -z "$panel_path" ]] && { echo "err: PANEL_PATH is empty in $env_file" >&2; exit 1; }
    sqlite3 "$db_file" "UPDATE settings SET value='$panel_path' WHERE key='webBasePath';"
    VARS[panel_path]="$panel_path"
    echo "[*] updated webBasePath in $db_file to '$panel_path'"
}

main() {
    is_root && { echo "err: run as root is forbidden, exit" >&2; exit 1; }
    install_docker
    configure_sysctl
    ask_domain
    set_domain
    set_caddy_env
    cp_compose_file
    install_sqlite
    init_panel_db
    set_panel_path
    echo "panel is available at: ${VARS[domain]}/${VARS[panel_path]}"
    echo "[+] done, reboot"
}

main "$@"
