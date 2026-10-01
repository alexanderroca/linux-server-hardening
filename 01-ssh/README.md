# Debian 12 Hardening Lab (Vagrant + VirtualBox)

Technical documentation, configuration guide, and reference architecture for a local test environment based on **Debian Bookworm (v12)**, virtualized via **Vagrant** and **VirtualBox** on a **Windows** host, focusing on automated reproducibility and security best practices.

---

## 🛠️ Prerequisites

Before spinning up the environment, ensure you have the following installed on your Windows host:
- [VirtualBox](https://www.virtualbox.org/) (version 7.x recommended).
- [Vagrant](https://www.vagrantup.com/).
- A Bash-compatible terminal (Bash, PowerShell).

---

## ⚙️ Environment Configuration (`Vagrantfile`)

The `Vagrantfile` defines hardware resources, shared folder synchronization, and port forwarding adapted to support SSH service hardening.

```Ruby
Vagrant.configure("2") do |config|
  # Use official Debian Bookworm (64-bit) base box
  config.vm.box = "debian/bookworm64"

  # Force Vagrant to use port 2222 for its internal SSH control channel
  config.ssh.port = 2222

  # Port forwarding so the host can connect to guest's port 2222
  config.vm.network "forwarded_port", guest: 2222, host: 2222

  # Hardware resource allocation for the test VM
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024" # 1 GB RAM
    vb.cpus   = 2      # 2 CPU Cores
  end
end
```

## Environment Management Commands

- Start the virtual machine: `vagrant up`
- Access the VM terminal: `vagrant ssh`
- Safely stop the VM: `vagrant halt`
- Destroy the environment (full cleanup): `vagrant destroy -f`

## Module 01: SSH Hardening (`01-ssh`)

Modern Debian utilizes a modular drop-in directory (`/etc/ssh/sshd_config.d/`) that isolates security rules and prevents system upgrades from overwriting custom configurations.

### 1. User Directory and Key Setup

Configure the key environment for your standard user (avoiding the `root` home directory):

```Bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Add your public key with a descriptive identifier:

```Bash
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... user@laptop personal-laptop" >> ~/.ssh/authorized_keys
```

### 2. Drop-in Configuration Files

#### A. Base Directives (`hardening.conf`)

Create and edit the core restriction file:

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

Isolate key exchange algorithms, ciphers, and message authentication codes:

```Bash
sudo vim /etc/ssh/sshd_config.d/crypto-hardening.conf
```

Content:

```Plaintext
# Modern Key Exchange Algorithms
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512

# High-Performance, Secure Ciphers
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com

# Encrypted-then-MAC (EtM) Message Authentication Codes
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
```

#### C. Session Management and Tunnels (`session-hardening.conf`)

Control idle timeouts and block unnecessary port forwarding features:

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

### 3. Automated Deployment (`install.sh`)

Instead of applying settings manually, the module includes an automation script (`install.sh`) that installs dependencies, deploys drop-in files with correct permissions, runs mandatory syntax checks, and restarts the service safely.

Create `install.sh` with the following content:

```Bash
#!/bin/bash
set -e

echo "[+] Configuring module 01-ssh (Modular Hardening)..."

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

### 4. Verification and Testing

1. Run the installation script inside the VM:

```Bash
cd /vagrant/01-ssh
sudo bash install.sh
```

2. Execute the automated Test Suite (`test.sh`):

Certify programmatically that the active configuration matches security requirements:

```Bash
sudo bash test.sh
```