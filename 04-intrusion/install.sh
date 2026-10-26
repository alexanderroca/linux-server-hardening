#!/bin/bash
set -e

echo "[+] Configuring module 04-intrusion (Fail2ban & AIDE)..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export DEBIAN_FRONTEND=noninteractive

# 1. Install Fail2ban and AIDE
echo "[*] Installing fail2ban and aide packages..."
apt-get update
apt-get install -y fail2ban aide

# 2. Configure Fail2ban SSH jail with nftables backend and port 2222
echo "[*] Configuring Fail2ban SSH jail..."
mkdir -p /etc/fail2ban/jail.d
cat << 'EOF' > /etc/fail2ban/jail.d/ssh-hardening.local
[DEFAULT]
bantime = 10m
findtime = 600
maxretry = 3
banaction = nftables-multiport
banaction_allports = nftables-allports

[sshd]
enabled = true
port = 2222
mode = normal
logpath = %(sshd_log)s
backend = %(sshd_backend)s
maxretry = 3
bantime = 10m
EOF
chmod 644 /etc/fail2ban/jail.d/ssh-hardening.local

# 3. Configure AIDE Exclusions at the tail of aide.conf
echo "[*] Applying AIDE volatile state exclusions..."
AIDE_CONF="/etc/aide/aide.conf"
if ! grep -q "Override: Force Ignore Volatile Logs" "$AIDE_CONF"; then
    cat << 'EOF' >> "$AIDE_CONF"

# --- Override: Force Ignore Volatile Logs & State ---
!/var/log/.*
!/var/lib/faillock/.*
!/run/NetworkManager/.*
!/var/lib/NetworkManager/.*
!/home/r4k00n/\.bash_history$
!/var/spool/anacron/.*
EOF
fi

# 4. Initialize AIDE database non-interactively
echo "[*] Initializing AIDE database..."
if [ ! -f /var/lib/aide/aide.db ]; then
    aideinit || true
    if [ -f /var/lib/aide/aide.db.new ]; then
        cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    fi
fi

# 5. Set up AIDE Systemd Service & Timer for daily checks
echo "[*] Setting up AIDE systemd automation..."
cat << 'EOF' > /etc/systemd/system/aide-check.service
[Unit]
Description=AIDE File Integrity Check
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/bin/aide --check --config /etc/aide/aide.conf
SuccessExitStatus=0 1
EOF

cat << 'EOF' > /etc/systemd/system/aide-check.timer
[Unit]
Description=Run AIDE File Integrity Check Daily
Requires=aide-check.service

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=15m

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now aide-check.timer

# 6. Enable and Start Fail2ban
echo "[*] Enabling and starting fail2ban service..."
systemctl enable fail2ban
systemctl restart fail2ban

echo "[✔] Module 04-intrusion applied successfully."
