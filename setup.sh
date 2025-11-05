#!/usr/bin/env bash
set -eEuo pipefail
trap 'echo "err: $BASH_COMMAND on line $LINENO" >&2' ERR

BASE_DIR="$(dirname "$(realpath "$0")")"

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

main() {
    is_root && { echo "err: run as root is forbidden, exit" >&2; exit 1; }
    install_docker
    configure_sysctl
    echo "[+] done, reboot"
}

main "$@"
