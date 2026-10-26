#!/bin/bash
echo "[*] Running verification suite for module 06-kernel..."
FAILED=0

# 1. Check if blacklist file exists
if [ -f /etc/modprobe.d/99-security-blacklist.conf ]; then
    echo "[*] Checking if 99-security-blacklist.conf exists... [✔] OK"
else
    echo "[*] Checking if 99-security-blacklist.conf exists... [-] FAILED"
    FAILED=$((FAILED + 1))
fi

# 2. Verify cramfs module blacklisting (using dry-run -n and verbose -v)
if modprobe -n -v cramfs 2>&1 | grep -q "/bin/true"; then
    echo "[*] Verifying cramfs blacklisting mapping... [✔] OK"
else
    echo "[*] Verifying cramfs blacklisting mapping... [-] FAILED"
    FAILED=$((FAILED + 1))
fi

# 3. Verify sctp protocol blacklisting
if modprobe -n -v sctp 2>&1 | grep -q "/bin/true"; then
    echo "[*] Verifying sctp protocol blacklisting mapping... [✔] OK"
else
    echo "[*] Verifying sctp protocol blacklisting mapping... [-] FAILED"
    FAILED=$((FAILED + 1))
fi

echo "--------------------------------------------------"
if [ $FAILED -eq 0 ]; then
    echo "[✔] All kernel verification tests passed successfully!"
    exit 0
else
    echo "[-] Verification failed with $FAILED error(s)."
    exit 1
fi
