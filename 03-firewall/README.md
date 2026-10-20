# Module 03: Firewall Hardening (`nftables`)

## Overview

This module configures a modern, stateful, modular firewall using `nftables` on Debian 13 (Trixie). It replaces legacy `iptables` with a clean, high-performance architecture that enforces a default-deny security posture for all inbound traffic while dynamically including modular rule fragments.

## Core Security Design

1. **Default Policies**:
  - **Input**: `DROP` (Blocks all unrequested incoming traffic by default).
  - **Forward**: `DROP` (Disables packet forwarding unless explicitly configured).
  - **Output**: `ACCEPT` (Allows outbound system traffic).
2. **Core Inbound Rules**:
  - **Stateful Connection Tracking**: Explicitly accepts established and related traffic (`ct state established,related accept`).
  - **Loopback Interface**: Allows internal communication on `lo` (`iifname "lo" accept`).
  - **ICMP / Ping**: Permits basic diagnostic ping requests (`ip protocol icmp accept`, `meta l4proto ipv6-icmp accept`).
3. **Modular Rule Directory** (`/etc/nftables.d/`):
  - The base configuration (`/etc/nftables.conf`) dynamically includes all `.nft` files inside `/etc/nftables.d/`.
  - Service exceptions (such as SSH) are deployed into separate rule fragments (e.g., `/etc/nftables.d/ssh.nft`), enabling clean, modular management without editing the primary ruleset file.

## Architecture & Directory Structure

```Plaintext
03-firewall/
├── README.md       # Module documentation
├── nftables.conf   # Base nftables ruleset template
├── install.sh      # Automated, idempotent installer
└── test.sh         # Automated verification test suite
```

## File Contents

### Base Configuration (`nftables.conf`)

Located at `/etc/nftables.conf`:

```Bash
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority filter; policy drop;

        # Allow established and related incoming connections
        ct state established,related accept

        # Allow local loopback interface
        iifname "lo" accept

        # Allow ICMP ping
        ip protocol icmp accept
        meta l4proto ipv6-icmp accept

        # Include modular rule files from nftables.d
        include "/etc/nftables.d/*.nft"
    }

    chain forward {
        type filter hook forward priority filter; policy drop;
    }

    chain output {
        type filter hook output priority filter; policy accept;
    }
}
```

### SSH Rule Fragment (`/etc/nftables.d/ssh.nft`)

```Bash
# Allow SSH
tcp dport 2222 accept
```

### Installation & Deployment

To apply Module 03 on the virtual machine:

```Bash
sudo bash /vagrant/03-firewall/install.sh
```

#### Script Actions (`install.sh`):

1. Installs the `nftables` package non-interactively via `apt-get`.
2. Deploys `/etc/nftables.conf` with proper permissions (`644`).
3. Creates the modular directory `/etc/nftables.d/`.
4. Provisions the baseline SSH rule at `/etc/nftables.d/ssh.nft`.
5. Enables and restarts the `nftables` service.

## Verification & Testing

To run the automated verification suite:

```Bash 
sudo bash /vagrant/03-firewall/test.sh
```

### Manual Verification Commands:

1. **Check active ruleset**:

```Bash
sudo nft list ruleset
```

2. **Verify service status**:

```Bash
sudo systemctl status nftables
```

3. **Verify modular directory content**:

```Bash
ls -la /etc/nftables.d/
```
