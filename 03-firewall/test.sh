#!/bin/bash
echo "[*] Running verification suite for module 03-firewall..."
FAILED=0

# 1. Check if nftables package is installed
if dpkg -l | grep -q nftables; then
    echo "[*] Checking if nftables is installed... [✔] OK"
else
    echo "[*] Checking if nftables is installed... [-] FAILED: package not found."
    FAILED=$((FAILED + 1))
fi

# 2. Check if modular directory exists
if [ -d "/etc/nftables.d" ]; then
    echo "[*] Checking /etc/nftables.d directory... [✔] OK"
else
    echo "[*] Checking /etc/nftables.d directory... [-] FAILED: directory missing."
    FAILED=$((FAILED + 1))
fi

# 3. Verify input policy is set to drop
if nft list ruleset | grep -q "policy drop"; then
    echo "[*] Verifying default input drop policy... [✔] OK"
else
    echo "[*] Verifying default input drop policy... [-] FAILED: default drop policy not detected."
    FAILED=$((FAILED + 1))
fi

echo "--------------------------------------------------"
if [ $FAILED -eq 0 ]; then
    echo "[✔] All firewall verification tests passed successfully!"
    exit 0
else
    echo "[-] Verification failed with $FAILED error(s)."
    exit 1
fi
