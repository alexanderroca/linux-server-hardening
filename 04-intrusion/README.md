# Module 04: Intrusion Detection & Prevention (Fail2ban & AIDE)

## Overview

This module establishes robust host-based intrusion detection and automated prevention on Debian 13 (Trixie) by combining **AIDE (Advanced Intrusion Detection Environment)** for file integrity monitoring and **Fail2ban** for dynamic brute-force mitigation integrated with `nftables`.

---

## 1. File Integrity Monitoring (AIDE)

### Architecture & Noise Reduction
Out-of-the-box AIDE configurations often flag volatile state files (e.g., login logs, command history, DHCP leases), leading to severe alert fatigue. 

To overcome AIDE's "first match wins" rule precedence, absolute negative override rules (`!`) are appended to the **tail** of `/etc/aide/aide.conf`. This ensures volatile paths are intercepted and halted before default monitoring hooks trigger:
```plaintext
# --- Override: Force Ignore Volatile Logs & State ---
!/var/log/.*
!/var/lib/faillock/.*
!/run/NetworkManager/.*
!/var/lib/NetworkManager/.*
!/home/r4k00n/\.bash_history\$
!/var/spool/anacron/.*
```

## Systemd Automation

Integrity checks run automatically via a native systemd timer and service (`aide-check.timer` and `aide-check.service`). Because AIDE returns exit status `1` when non-critical differences or warnings are detected, `SuccessExitStatus=0 1` is configured so systemd treats expected runs as successful executions rather than unit failures.

# 2. Brute-Force Prevention (Fail2ban)

## Integration & Jail Configuration

Fail2ban is configured via modular override files in `/etc/fail2ban/jail.d/ssh-hardening.local` to protect the SSH service without modifying global templates.

- **Firewall Backend**: Uses `nftables-multiport` to ban malicious IPs directly in the host's `nftables` tables.
- **Port Target**: Monitors custom SSH port `2222`.
- **Thresholds**: Enforces a strict `maxretry = 3` and a `bantime = 10m` matching system lockout parameters.

# 3. Operational & Verification Commands

## Re-initializing the AIDE Database

Whenever system rules or exclusions are modified, re-sync the baseline database:

```Bash
sudo aideinit
```

## Running Manual Integrity Checks

Verify system integrity against the locked baseline:

```Bash
sudo aide --check --config /etc/aide/aide.conf
```

## Managing Systemd AIDE Timer

Verify that the daily AIDE check timer is active and scheduled:

```Bash
sudo systemctl list-timers aide-check.timer
```

## Monitoring Fail2ban Jails

Check the active status of your SSH protection jail and review banned IPs:

```Bash
sudo fail2ban-client status sshd
```

## Executing Module Scripts

- **Install**: `sudo bash /vagrant/04-intrusion/install.sh`
- **Test**: `sudo bash /vagrant/04-intrusion/test.sh`
