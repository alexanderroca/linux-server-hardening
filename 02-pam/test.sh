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

echo "[*] Running verification suite for module 02-pam..."

FAILED=0

# 1. Verify required packages are installed
echo -n "[*] Checking if libpam-pwquality is installed... "
if dpkg -l | grep -q libpam-pwquality; then
    echo "[✔] OK"
else
    echo "[-] FAILED: libpam-pwquality is not installed."
    FAILED=$((FAILED + 1))
fi

# 2. Verify configuration files exist
echo -n "[*] Checking /etc/security/pwquality.conf... "
if [ -f "/etc/security/pwquality.conf" ]; then
    echo "[✔] OK"
else
    echo "[-] FAILED: /etc/security/pwquality.conf is missing."
    FAILED=$((FAILED + 1))
fi

echo -n "[*] Checking /etc/security/faillock.conf... "
if [ -f "/etc/security/faillock.conf" ]; then
    echo "[✔] OK"
else
    echo "[-] FAILED: /etc/security/faillock.conf is missing."
    FAILED=$((FAILED + 1))
fi

# 3. Verify pwquality parameters inside configuration (robust match)
echo -n "[*] Verifying minlen = 14 in pwquality.conf... "
if grep -qE '^[[:space:]]*minlen[[:space:]]*=[[:space:]]*14' /etc/security/pwquality.conf; then
    echo "[✔] OK"
else
    echo "[-] FAILED: minlen is not set to 14."
    FAILED=$((FAILED + 1))
fi

# 4. Verify faillock profile integration via pam-auth-update
echo -n "[*] Checking if pam-auth-update has faillock enabled... "
if debconf-show libpam-runtime 2>/dev/null | grep -q "faillock"; then
    echo "[✔] OK"
else
    echo "[-] FAILED: faillock profile is not enabled in pam-auth-update."
    FAILED=$((FAILED + 1))
fi

# 5. Verify common-auth hooks for pam_faillock
echo -n "[*] Checking common-auth for pam_faillock hooks... "
if grep -q "pam_faillock.so" /etc/pam.d/common-auth; then
    echo "[✔] OK"
else
    echo "[-] FAILED: pam_faillock hooks missing from /etc/pam.d/common-auth."
    FAILED=$((FAILED + 1))
fi

echo "--------------------------------------------------"
if [ $FAILED -eq 0 ]; then
    echo "[✔] All PAM verification tests passed successfully!"
    exit 0
else
    echo "[-] Verification failed with $FAILED error(s)."
    exit 1
fi
