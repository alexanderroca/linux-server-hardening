#!/bin/bash
set -e

echo "=================================================="
echo "    RUNNING TEST SUITE: MODULE 01-SSH"
echo "=================================================="

FAILED_TESTS=0

# Test 1: Verificar que la sintaxis de la configuración de SSH es válida
echo "[Test 1] Validating SSH daemon configuration syntax (sshd -t)..."
if sshd -t; then
    echo "  [PASS] SSH configuration syntax is valid."
else
    echo "  [FAIL] SSH configuration syntax has errors."
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 2: Validar que la autenticación por contraseña está estrictamente deshabilitada
echo "[Test 2] Checking PasswordAuthentication status..."
PW_AUTH=$(sshd -T | grep -i "^passwordauthentication" | awk '{print $2}')
if [ "$PW_AUTH" = "no" ]; then
    echo "  [PASS] PasswordAuthentication is disabled (Value: $PW_AUTH)."
else
    echo "  [FAIL] PasswordAuthentication is enabled or misconfigured (Value: $PW_AUTH)."
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 3: Validar que el inicio de sesión como root por SSH está bloqueado
echo "[Test 3] Checking PermitRootLogin status..."
ROOT_LOGIN=$(sshd -T | grep -i "^permitrootlogin" | awk '{print $2}')
if [ "$ROOT_LOGIN" = "no" ] || [ "$ROOT_LOGIN" = "prohibit-password" ]; then
    echo "  [PASS] PermitRootLogin is securely configured (Value: $ROOT_LOGIN)."
else
    echo "  [FAIL] PermitRootLogin is too permissive (Value: $ROOT_LOGIN)."
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 4: Validar que los archivos de configuración drop-in existen en /etc/ssh/sshd_config.d/
echo "[Test 4] Checking drop-in hardening configuration files..."
EXPECTED_FILES=("hardening.conf" "crypto-hardening.conf" "session-hardening.conf")
for file in "${EXPECTED_FILES[@]}"; do
    if [ -f "/etc/ssh/sshd_config.d/$file" ]; then
        echo "  [PASS] Drop-in file '$file' exists."
    else
        echo "  [FAIL] Drop-in file '$file' is missing."
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
done

echo "=================================================="
if [ "$FAILED_TESTS" -eq 0 ]; then
    echo " RESULT: ALL SSH TESTS PASSED SUCCESSFULLY. [01-SSH BLINDED]"
    echo "=================================================="
    exit 0
else
    echo " RESULT: $FAILED_TESTS TEST(S) FAILED."
    echo "=================================================="
    exit 1
fi