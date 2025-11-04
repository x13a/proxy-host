#!/usr/bin/env bash
set -eEuo pipefail
trap 'echo "error at $BASH_COMMAND on line $LINENO" >&2' ERR

BASE_DIR="$(dirname "$(realpath "$0")")"

is_root() {
    [ "$(id -u)" -eq 0 ]
}

install_docker() {
    if command -v docker >/dev/null 2>&1; then
        return 0
    fi
    echo "installing docker..." >&2
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm ./get-docker.sh
    sudo groupadd -f docker
    sudo usermod -aG docker "$(whoami)"
}

configure_sysctl() {
    local target_file="/etc/sysctl.d/proxy.conf"
    echo "configuring sysctl..." >&2
    sudo cp "$BASE_DIR/$target_file" "$target_file"
    sudo chown root:root "$target_file"
    sudo chmod 644 "$target_file"
    echo "sysctl config deployed to $target_file" >&2
}

main() {
    if is_root; then
        echo "run as root is forbidden, exit" >&2
        exit 1
    fi
    install_docker
    configure_sysctl
    echo "done, reboot" >&2
}

main "$@"
