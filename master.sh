#!/bin/bash
set -e

# Define ordered modules list
MODULES=(
    "01-ssh"
    "02-pam"
    "03-firewall"
    "04-intrusion"
    "05-audit"
    "06-kernel"
    "07-updates"
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOTAL=${#MODULES[@]}

# ANSI Color Codes for visual status feedback
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=================================================="
echo " Starting Master Hardening Deployment (Debian 13)"
echo "=================================================="

# --- PHASE 1: INSTALLATION ---
echo ""
echo -e "${BLUE}[+] PHASE 1: Executing module installation scripts...${NC}"
CURRENT=1

for mod in "${MODULES[@]}"; do
    INSTALL_SCRIPT="$SCRIPT_DIR/$mod/install.sh"
    if [ -f "$INSTALL_SCRIPT" ]; then
        echo -e "--------------------------------------------------"
        echo -e "${YELLOW}[${CURRENT}/${TOTAL}] ⏳ In Progress: Installing module [${mod}]...${NC}"
        echo -e "--------------------------------------------------"
        sudo bash "$INSTALL_SCRIPT"
        echo -e "${GREEN}[✔] Completed: ${mod} installed successfully.${NC}"
    else
        echo -e "${RED}[-] Error: install.sh not found for ${mod}!${NC}"
        exit 1
    fi
    CURRENT=$((CURRENT + 1))
done

echo ""
echo "=================================================="
echo -e "${GREEN}[✔] All installation scripts completed successfully!${NC}"
echo "=================================================="

# --- PHASE 2: VERIFICATION ---
echo ""
echo -e "${BLUE}[+] PHASE 2: Executing verification test suites...${NC}"
FAILED_TESTS=0
CURRENT=1

for mod in "${MODULES[@]}"; do
    TEST_SCRIPT="$SCRIPT_DIR/$mod/test.sh"
    if [ -f "$TEST_SCRIPT" ]; then
        echo -e "--------------------------------------------------"
        echo -e "${YELLOW}[${CURRENT}/${TOTAL}] ⏳ Verifying module [${mod}]...${NC}"
        echo -e "--------------------------------------------------"
        if sudo bash "$TEST_SCRIPT"; then
            echo -e "${GREEN}[✔] Module ${mod} tests PASSED.${NC}"
        else
            echo -e "${RED}[-] Module ${mod} tests FAILED.${NC}"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        echo -e "${RED}[-] Warning: test.sh not found for ${mod}, skipping.${NC}"
    fi
    CURRENT=$((CURRENT + 1))
done

echo ""
echo "=================================================="
if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}[✔] Master execution complete: ALL 7 modules installed and verified successfully!${NC}"
    exit 0
else
    echo -e "${RED}[-] Master execution finished with ${FAILED_TESTS} failing test suite(s).${NC}"
    exit 1
fi
