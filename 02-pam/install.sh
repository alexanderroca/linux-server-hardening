#!/bin/bash
set -e

# Dynamically resolve script execution directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$SCRIPT_DIR/pwquality.conf" ]; then
    if [ -f "/vagrant/02-pam/pwquality.conf" ]; then
        SCRIPT_DIR="/vagrant/02-pam"
    elif [ -f "./pwquality.conf" ]; then
        SCRIPT_DIR="."
    else
        echo "[-] Error: PAM configuration files could not be found!" >&2
        exit 1
    fi
fi

cd "$SCRIPT_DIR"

echo "[+] Configuring module 02-pam (Password Quality & Lockout)..."

# 1. Install required PAM modules
apt update && apt install -y libpam-pwquality libpam-modules

# 2. Deploy pwquality configuration
echo "[*] Deploying pwquality.conf..."
cp pwquality.conf /etc/security/pwquality.conf
chmod 644 /etc/security/pwquality.conf

# 3. Deploy faillock configuration
echo "[*] Deploying faillock.conf..."
cp faillock.conf /etc/security/faillock.conf
chmod 644 /etc/security/faillock.conf

# 4. Deploy native pam-auth-update profile
echo "[*] Deploying pam-auth-update profile..."
cp faillock /etc/pam-configs/faillock
chmod 644 /etc/pam-configs/faillock

# 5. Apply the profile non-interactively via Debian package hooks
echo "[*] Updating PAM authentication stack..."
pam-auth-update --package

echo "[✔] Module 02-pam applied successfully."
