#!/bin/bash
echo "[*] Running verification suite for module 05-audit..."
FAILED=0

# 1. Check if auditd is installed
if dpkg -l | grep -q auditd; then
    echo "[*] Checking if auditd is installed... [✔] OK"
else
    echo "[*] Checking if auditd is installed... [-] FAILED: package missing"
    FAILED=$((FAILED + 1))
fi

# 2. Check if auditd daemon is active
if service auditd status | grep -q "active (running)" || systemctl is-active --quiet auditd; then
    echo "[*] Checking if auditd daemon is running... [✔] OK"
else
    echo "[*] Checking if auditd daemon is running... [-] FAILED: service not active"
    FAILED=$((FAILED + 1))
fi

# 3. Check if audit rules are active in kernel
if sudo auditctl -l | grep -E "(identity|privileged-actions)"; then
    echo "[*] Verifying identity/privileged audit watches... [✔] OK"
else
    echo "[*] Verifying identity/privileged audit watches... [-] FAILED"
    FAILED=$((FAILED + 1))
fi

# 4. Check if ruleset is locked/immutable (-e 2)
if sudo auditctl -s | grep -q "enabled 2"; then
    echo "[*] Verifying immutable lock status (-e 2)... [✔] OK"
else
    echo "[*] Verifying immutable lock status (-e 2)... [-] FAILED (lock not set)"
    FAILED=$((FAILED + 1))
fi

echo "--------------------------------------------------"
if [ $FAILED -eq 0 ]; then
    echo "[✔] All auditd verification tests passed successfully!"
    exit 0
else
    echo "[-] Verification failed with $FAILED error(s)."
    exit 1
fi
