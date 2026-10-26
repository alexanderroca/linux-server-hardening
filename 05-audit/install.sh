#!/bin/bash
set -e

echo "[+] Configuring module 05-audit (auditd)..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 1. Install auditd non-interactively
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y auditd audispd-plugins

# 2. Clean legacy configuration and deploy 99-security-audit.rules securely
echo "[*] Deploying audit rules to /etc/audit/rules.d/..."
rm -f /etc/audit/rules.d/audit.rules
cp "${SCRIPT_DIR}/99-security-audit.rules" /etc/audit/rules.d/99-security-audit.rules
chmod 640 /etc/audit/rules.d/99-security-audit.rules

# 3. Compile and load rules into the kernel
echo "[*] Compiling audit rules with augenrules..."
augenrules --load

# 4. Restart auditd service
echo "[*] Restarting auditd service..."
service auditd restart || systemctl restart auditd

echo "[✔] Module 05-audit applied successfully."
