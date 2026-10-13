#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$SCRIPT_DIR/hardening.conf" ]; then
    if [ -f "/vagrant/01-ssh/hardening.conf" ]; then
        SCRIPT_DIR="/vagrant/01-ssh"
    elif [ -f "./hardening.conf" ]; then
        SCRIPT_DIR="."
    else
        echo "[-] Error: Configuration files could not be found!" >&2
        exit 1
    fi
fi

cd "$SCRIPT_DIR"

echo "[+] Configuring module 01-ssh (Source: $SCRIPT_DIR)..."

apt update && apt install -y openssh-server
mkdir -p /etc/ssh/sshd_config.d

cp hardening.conf /etc/ssh/sshd_config.d/hardening.conf
cp crypto-hardening.conf /etc/ssh/sshd_config.d/crypto-hardening.conf
cp session-hardening.conf /etc/ssh/sshd_config.d/session-hardening.conf

chmod 644 /etc/ssh/sshd_config.d/*.conf

cp issue.net /etc/issue.net
chmod 644 /etc/issue.net

sshd -t

systemctl restart ssh
systemctl enable ssh

echo "[✔] Module 01-ssh applied successfully."
