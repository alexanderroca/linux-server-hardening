#!/bin/bash
set -e

echo "[+] Configuring module 07-updates (Automatic Updates & Kernel Tuning)..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export DEBIAN_FRONTEND=noninteractive

# 1. Install unattended-upgrades non-interactively
echo "[*] Installing unattended-upgrades..."
apt-get update
apt-get install -y unattended-upgrades

# Enable unattended-upgrades automatically
echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
dpkg-reconfigure -f noninteractive unattended-upgrades

# 2. Deploy sysctl security configuration
echo "[*] Deploying 99-security.conf to /etc/sysctl.d/..."
cp 99-security.conf /etc/sysctl.d/99-security.conf
chmod 644 /etc/sysctl.d/99-security.conf

# 3. Apply sysctl parameters immediately
echo "[*] Applying sysctl kernel parameters..."
sysctl --system

echo "[✔] Module 07-updates applied successfully."
