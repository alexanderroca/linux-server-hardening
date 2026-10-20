#!/bin/bash
set -e

echo "[+] Configuring module 02-pam (Password Quality & Lockout)..."

# Dynamically resolve script execution directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 1. Ensure required packages are installed non-interactively
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y libpam-pwquality libpam-modules

# 2. Deploy and configure pwquality.conf (Idempotent)
echo "[*] Deploying pwquality.conf..."
cp pwquality.conf /etc/security/pwquality.conf
chmod 644 /etc/security/pwquality.conf

if grep -qE "^\s*#?\s*minlen\s*=" /etc/security/pwquality.conf; then
    sed -i 's/^#\?\s*minlen\s*=.*/minlen = 14/' /etc/security/pwquality.conf
else
    echo "minlen = 14" >> /etc/security/pwquality.conf
fi

# 3. Deploy faillock.conf
echo "[*] Deploying faillock.conf..."
cp faillock.conf /etc/security/faillock.conf
chmod 644 /etc/security/faillock.conf

# 4. Deploy pam-auth-update profile to system-wide directory
echo "[*] Ensuring /usr/share/pam-configs directory exists..."
mkdir -p /usr/share/pam-configs

echo "[*] Deploying pam-auth-update profile..."
cp faillock /usr/share/pam-configs/faillock
chmod 644 /usr/share/pam-configs/faillock

# 5. Update PAM authentication stack non-interactively
echo "[*] Updating PAM authentication stack..."
pam-auth-update --enable faillock --force

echo "[✔] Module 02-pam applied successfully."
