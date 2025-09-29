#!/usr/bin/env bash
set -euo pipefail

install_docker() {
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh

    rm ./get-docker.sh
    sudo groupadd -f docker
    sudo usermod -aG docker $USER
}

install_sysctl_config() {
    sudo cp ./etc/sysctl.d/vpn.conf /etc/sysctl.d/
}

install_docker
install_sysctl_config
echo "done, reboot"
