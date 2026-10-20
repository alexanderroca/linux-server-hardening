#!/bin/bash
set -e

echo "[+] Configuring module 03-firewall (nftables modular)..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 1. Install nftables non-interactively
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nftables

# 2. Deploy main configuration and create modular directory
echo "[*] Deploying base nftables.conf and creating /etc/nftables.d..."
cp nftables.conf /etc/nftables.conf
chmod 644 /etc/nftables.conf
mkdir -p /etc/nftables.d

# 3. Deploy default SSH rule (adjust port if needed, using 22 for standard setup)
echo "[*] Deploying SSH modular rule..."
cat << 'EOF' > /etc/nftables.d/ssh.nft
# Allow SSH
tcp dport 22 accept
EOF
chmod 644 /etc/nftables.d/ssh.nft

# 4. Enable and start nftables service
echo "[*] Enabling and starting nftables service..."
systemctl enable nftables
systemctl restart nftables

echo "[✔] Module 03-firewall applied successfully."
