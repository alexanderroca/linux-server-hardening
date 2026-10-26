#!/bin/bash
echo "[*] Running verification suite for module 04-intrusion..."
FAILED=0

# 1. Check Fail2ban service
if dpkg -l | grep -q fail2ban && systemctl is-active --quiet fail2ban; then
    echo "[*] Checking Fail2ban service... [✔] OK"
else
    echo "[*] Checking Fail2ban service... [-] FAILED"
    FAILED=$((FAILED + 1))
fi

# 2. Check Fail2ban sshd jail status
if sudo fail2ban-client status sshd | grep -q "Status for the jail: sshd"; then
    echo "[*] Verifying Fail2ban sshd jail... [✔] OK"
else
    echo "[*] Verifying Fail2ban sshd jail... [-] FAILED"
    FAILED=$((FAILED + 1))
fi

# 3. Check AIDE package and database
if dpkg -l | grep -q aide && [ -f /var/lib/aide/aide.db ]; then
    echo "[*] Verifying AIDE installation and database... [✔] OK"
else
    echo "[*] Verifying AIDE installation and database... [-] FAILED"
    FAILED=$((FAILED + 1))
fi

# 4. Check AIDE systemd timer
if systemctl is-enabled --quiet aide-check.timer; then
    echo "[*] Verifying AIDE systemd timer... [✔] OK"
else
    echo "[*] Verifying AIDE systemd timer... [-] FAILED"
    FAILED=$((FAILED + 1))
fi

echo "--------------------------------------------------"
if [ $FAILED -eq 0 ]; then
    echo "[✔] All intrusion detection verification tests passed successfully!"
    exit 0
else
    echo "[-] Verification failed with $FAILED error(s)."
    exit 1
fi
