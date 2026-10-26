# Module 05: Linux Audit Framework (`auditd`) Hardening

This module documents and automates system-wide kernel event auditing using `auditd` on Debian 13 (Trixie), ensuring forensic visibility into sensitive file modifications, identity changes, and privileged administrative actions.

---

## 1. Architecture & Modular Rules

Instead of monolithic configuration files, audit rules on Debian are dynamically compiled from individual files inside `/etc/audit/rules.d/` using `augenrules`.

### Configuration Rules (`/etc/audit/rules.d/99-security-audit.rules`)

```plaintext
## First rule - delete all existing rules to start clean
-D

## Increase buffers to survive high-stress logging events
-b 8192

## Set how long to wait during burst events (milliseconds)
--backlog_wait_time 60000

## Set failure mode to syslog (1 = log kernel failure)
-f 1

## --- Identity & Authentication Monitoring ---
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/gshadow -p wa -k identity

## --- Privileged Actions & Sudoers ---
-w /etc/sudoers -p wa -k privileged-actions
-w /etc/sudoers.d -p wa -k privileged-actions

## --- Network Configuration ---
-w /etc/network -p wa -k network

## --- Make the Audit Configuration Immutable ---
-e 2
```

## 2. Key Concepts & Parameters Explained

- **Buffer Size** (`-b 8192`) **& Backlog Wait Time** (`--backlog_wait_time 60000`): Allocates kernel memory buffers to hold audit events during heavy system load, preventing dropped logs or system panics during burst traffic.
- **File Watches** (`-w`) **& Permissions** (`-p wa`): Monitors specified files for write (`w`) and attribute change (`a`) operations, tagging them with custom keys (e.g., `-k identity`, `-k privileged-actions`) for streamlined log analysis.
- **Immutable Lock** (`-e 2`): Locks the audit configuration so that rules cannot be modified or unloaded at runtime without a full system reboot, neutralizing attacker attempts to disable logging.

## 3. Execution & Verification

### Run Installation Script

Deploys packages, copies the rules file, compiles rules via `augenrules --load`, and restarts the daemon:

```Bash
sudo bash /vagrant/05-audit/install.sh
```
### Run Automated Verification Suite

Validates package installation, daemon status, kernel rule loading, and the immutable lock state

```Bash
sudo bash /vagrant/05-audit/test.sh
```

### Manual Verification

Verify that rules are compiled and active in the kernel:

```Bash
sudo auditctl -l
```

Verify kernel status and immutability lock level:

```Bash
sudo auditctl -s
```
