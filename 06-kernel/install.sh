#!/bin/bash
set -e

echo "[+] Configuring module 06-kernel (modprobe blacklisting)..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Ensure zstd is installed to prevent initramfs gzip compression hang
if ! dpkg -l | grep -q zstd; then
    echo "[*] Installing zstd for fast initramfs compression..."
    apt-get update && apt-get install -y zstd
fi

# Ensure config uses zstd compression
if grep -q "^#COMPRESS=" /etc/initramfs-tools/initramfs.conf; then
    sed -i 's/^#COMPRESS=.*/COMPRESS=zstd/' /etc/initramfs-tools/initramfs.conf
elif ! grep -q "^COMPRESS=" /etc/initramfs-tools/initramfs.conf; then
    echo "COMPRESS=zstd" >> /etc/initramfs-tools/initramfs.conf
else
    sed -i 's/^COMPRESS=.*/COMPRESS=zstd/' /etc/initramfs-tools/initramfs.conf
fi

# 1. Deploy modprobe security blacklist configuration
echo "[*] Deploying 99-security-blacklist.conf to /etc/modprobe.d/..."
cp 99-security-blacklist.conf /etc/modprobe.d/99-security-blacklist.conf
chmod 644 /etc/modprobe.d/99-security-blacklist.conf

# 2. Handle AppArmor constraints if applicable during initramfs generation
echo "[*] Checking AppArmor constraints for busybox..."
if command -v aa-complain &> /dev/null && [ -f /etc/apparmor.d/usr.bin.busybox ]; then
    aa-complain /usr/bin/busybox || true
fi

# 3. Update initial RAM filesystem cleanly
echo "[*] Updating initramfs..."
update-initramfs -u

# 4. Restore AppArmor strict enforcement if applicable
if command -v aa-enforce &> /dev/null && [ -f /etc/apparmor.d/usr.bin.busybox ]; then
    aa-enforce /usr/bin/busybox || true
fi

echo "[✔] Module 06-kernel applied successfully."
