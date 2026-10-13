# Debian 13 Hardening Lab (Vagrant + libvirt)

Technical documentation, configuration guide, and reference architecture for a local test environment based on **Debian Trixie (v13)**, virtualized via **Vagrant** and **libvirt/QEMU** on a Linux host, focusing on automated reproducibility and security best practices.

---

## 🛠️ Prerequisites

Before spinning up the environment, ensure you have the following installed on your host:
- [libvirt](https://libvirt.org/) and QEMU.
- [Vagrant](https://www.vagrantup.com/) with the `vagrant-libvirt` plugin.
- A Bash-compatible terminal.

---

## ⚙️ Environment Configuration (`Vagrantfile`)

The `Vagrantfile` defines hardware resources, shared folder synchronization, automated provisioning, and forces Vagrant to manage the management control channel over the hardened custom port (`2222`).

```Ruby
Vagrant.configure("2") do |config|
  # Use official Debian Trixie (64-bit) base box
  config.vm.box = "debian/trixie64"

  # Hardware resource allocation for the test VM
  config.vm.provider "libvirt" do |libvirt|
    libvirt.driver = "qemu"
    libvirt.memory = 1024 # 1 GB RAM
    libvirt.cpus   = 2    # 2 CPU Cores
  end

  # Target the hardened custom SSH control port
  config.ssh.port = 2222

  # Automatically run the SSH hardening script on initial bootstrap
  config.vm.provision "shell", path: "01-ssh/install.sh"
end
```

## Environment Management Commands

- Start the virtual machine: `vagrant up --provider=libvirt`
- Access the VM terminal: `vagrant ssh`
- Safely stop the VM: `vagrant halt`
- Destroy the environment (full cleanup): `vagrant destroy -f`

## Module 01: SSH Hardening (`01-ssh`)

Modern Debian utilizes a modular drop-in directory (`/etc/ssh/sshd_config.d/`) that isolates security rules and prevents system upgrades from overwriting custom configurations.

### 1. Drop-in Configuration Files

#### A. Base Directives (`hardening.conf`)

Core restrictions controlling access boundaries:

```Bash
sudo vim /etc/ssh/sshd_config.d/hardening.conf
```

Content:

```Plaintext
# ==========================================
# SSH Hardening Configuration
# ==========================================

# Disable root login entirely. Use a standard user with sudo.
PermitRootLogin no

# Enforce SSH key-based authentication only. Kill passwords.
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no

# Limit authentication attempts to slow down brute-forcers
MaxAuthTries 3

# Custom Port (Reduces automated bot noise)
Port 2222

# Legal Banner Message
Banner /etc/issue.net
```

*Legal banner notice (`/etc/issue.net`):*

```Plaintext
Warning! Authorized use only.
This server is the property of MyCompanyName.com
```

#### B. Modern Cryptography (`crypto-hardening.conf`)

Isolates high-security algorithms while maintaining strict client compatibility for automation stacks (like Vagrant's internal `Net::SSH` client):

```Bash
sudo vim /etc/ssh/sshd_config.d/crypto-hardening.conf
```

Content:

```Plaintext
# Modern & Compatible Key Exchange Algorithms
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512

# High-Performance, Secure Ciphers
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com

# Encrypted-then-MAC (EtM) Message Authentication Codes
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
```

#### C. Session Management and Tunnels (`session-hardening.conf`)

Controls idle timeouts and locks down unneeded forwarding vectors:

```Bash
sudo vim /etc/ssh/sshd_config.d/session-hardening.conf
```

Content:

```Plaintext
# --- Idle Timeouts ---
ClientAliveInterval 300
ClientAliveCountMax 2

# --- Subsystem & Forwarding Lockdown ---
AllowTcpForwarding no
AllowAgentForwarding no
X11Forwarding no
PermitTunnel no
```

### 2. Universal Automated Deployment (`install.sh`)

The deployment script dynamically resolves its execution context so it can run seamlessly via Vagrant provisioning or be executed manually on a standalone Debian instance.

Create `install.sh` with the following content:

```Bash
#!/bin/bash
set -e

# Dynamically locate where this script actually lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Fallback check for different execution environments
if [ ! -f "$SCRIPT_DIR/hardening.conf" ]; then
    if [ -f "/vagrant/01-ssh/hardening.conf" ]; then
        SCRIPT_DIR="/vagrant/01-ssh"
    elif [ -f "./hardening.conf" ]; then
        SCRIPT_DIR="."
    else
        echo "[-] Error: Configuration files could not be found!" >&2
        exit 1
    fi
fi

cd "$SCRIPT_DIR"

echo "[+] Configuring module 01-ssh (Source: $SCRIPT_DIR)..."

# 1. Ensure openssh-server is installed
apt update && apt install -y openssh-server

# 2. Ensure the SSH modular drop-in directory exists
mkdir -p /etc/ssh/sshd_config.d

# 3. Copy the modular configuration files
echo "[*] Copying SSH configuration files..."
cp hardening.conf /etc/ssh/sshd_config.d/hardening.conf
cp crypto-hardening.conf /etc/ssh/sshd_config.d/crypto-hardening.conf
cp session-hardening.conf /etc/ssh/sshd_config.d/session-hardening.conf

# Set strict read permissions on configuration files
chmod 644 /etc/ssh/sshd_config.d/*.conf

# 4. Copy and configure the legal banner
echo "[*] Configuring the warning banner..."
cp issue.net /etc/issue.net
chmod 644 /etc/issue.net

# 5. Mandatory strict syntax validation
echo "[*] Verifying SSH service syntax..."
sshd -t

# 6. Restart and enable the service
echo "[*] Restarting the SSH service..."
systemctl restart ssh
systemctl enable ssh

echo "[✔] Module 01-ssh applied successfully."
```

### 3. Verification and Testing

1. Automated Provisioning: Runs automatically on `vagrant up`.

2. Manual Execution (Standalone/Testing):

```Bash
sudo bash 01-ssh/install.sh
```

3. Direct Host Connection Check:

```Bash
ssh -p 2222 vagrant@<VM_IP> -i .vagrant/machines/default/libvirt/private_key
```
