#!/bin/bash
set -e

echo "[+] Configuring module 01-ssh (Modular Hardening)..."

# 1. Ensure openssh-server is installed
apt update && apt install -y openssh-server

# 2. Ensure the SSH modular drop-in directory exists
mkdir -p /etc/ssh/sshd_config.d

# 3. Copy the modular configuration files
echo "[*] Copying SSH configuration files..."
cp hardening.conf /etc/ssh/sshd_config.d/hardening.conf
cp crypto-hardening.conf /etc/ssh/sshd_config.d/crypto-hardening.conf
cp session-hardening.conf /etc/ssh/sshd_config.d/session-hardening.conf

# Set strict read permissions on configuration files
chmod 644 /etc/ssh/sshd_config.d/*.conf

# 4. Copy and configure the legal banner
echo "[*] Configuring the warning banner..."
cp issue.net /etc/issue.net
chmod 644 /etc/issue.net

# 5. Mandatory strict syntax validation
echo "[*] Verifying SSH service syntax..."
sshd -t

# 6. Restart and enable the service
echo "[*] Restarting the SSH service..."
systemctl restart ssh
systemctl enable ssh

echo "[✔] Module 01-ssh applied successfully."