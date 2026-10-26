#!/bin/bash
echo "[*] Running verification suite for module 07-updates..."
FAILED=0

# 1. Check unattended-upgrades installation and service status
if dpkg -l | grep -q unattended-upgrades; then
    echo "[*] Checking unattended-upgrades package... [✔] OK"
else
    echo "[*] Checking unattended-upgrades package... [-] FAILED"
    FAILED=$((FAILED + 1))
fi

# 2. Verify Reverse Path Filtering sysctl parameter
RP_VAL=$(sysctl -n net.ipv4.conf.all.rp_filter)
if [ "$RP_VAL" -eq 1 ]; then
    echo "[*] Verifying net.ipv4.conf.all.rp_filter = 1... [✔] OK"
else
    echo "[*] Verifying net.ipv4.conf.all.rp_filter = 1... [-] FAILED (got $RP_VAL)"
    FAILED=$((FAILED + 1))
fi

# 3. Verify symbolic link protection sysctl parameter
SYM_VAL=$(sysctl -n fs.protected_symlinks)
if [ "$SYM_VAL" -eq 1 ]; then
    echo "[*] Verifying fs.protected_symlinks = 1... [✔] OK"
else
    echo "[*] Verifying fs.protected_symlinks = 1... [-] FAILED (got $SYM_VAL)"
    FAILED=$((FAILED + 1))
fi

# 4. Verify kernel pointer restriction parameter
KPTR_VAL=$(sysctl -n kernel.kptr_restrict)
if [ "$KPTR_VAL" -eq 2 ]; then
    echo "[*] Verifying kernel.kptr_restrict = 2... [✔] OK"
else
    echo "[*] Verifying kernel.kptr_restrict = 2... [-] FAILED (got $KPTR_VAL)"
    FAILED=$((FAILED + 1))
fi

echo "--------------------------------------------------"
if [ $FAILED -eq 0 ]; then
    echo "[✔] All updates & kernel tuning verification tests passed successfully!"
    exit 0
else
    echo "[-] Verification failed with $FAILED error(s)."
    exit 1
fi
