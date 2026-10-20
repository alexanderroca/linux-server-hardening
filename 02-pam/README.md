# Module 02: PAM Hardening & Account Security

This module automates the security hardening of the Pluggable Authentication Modules (PAM) stack on Debian 13 (Trixie) using Infrastructure-as-Code (IaC) principles. It enforces strict password quality policy checks and account lockout rules against brute-force attacks in an idempotent and non-interactive fashion.

## 📋 Features & Compliance

Password Quality Enforcer (`libpam-pwquality`): Enforces a minimum password length of 14 characters (`minlen = 14`).

Account Lockout (`pam_faillock`): Tracks failed login attempts and locks out targeted accounts automatically.

PAM Integration (`pam-auth-update`): Deploys native system-wide profiles to `/usr/share/pam-configs/` and non-interactively updates `/etc/pam.d/common-auth`.

Self-Healing & Idempotent: Ensures `install.sh` can be re-run indefinitely without duplicate entries or configuration drift.

## 📂 Module Architecture

```Plaintext
02-pam/
├── README.md         # Module documentation (this file)
├── faillock          # Custom pam-auth-update profile header & hooks
├── faillock.conf     # Configuration for pam_faillock limits and timeouts
├── pwquality.conf    # Baseline configuration for password complexity
├── install.sh        # Idempotent automated installation & configuration script
└── test.sh           # Non-destructive automated verification test suite
```

## 🛠 Prerequisites

Ensure the deployment target meets the following requirements:

Operating System: Debian 13 (Trixie) or compatible system.

Privileges: Root or `sudo` access.

Dependencies: Clean network access to official Debian repositories (apt).

## 🚀 Step-by-Step Automation Guide

### Step 1: Deploy Configuration (`install.sh`)

Run the automated installer with superuser privileges. The script performs the following operations:

1. Installs `libpam-pwquality` and `libpam-modules` non-interactively (`DEBIAN_FRONTEND=noninteractive`).
2. Copies `pwquality.conf` and `faillock.conf` into `/etc/security/`.
3. Programmatically ensures `minlen = 14` in `/etc/security/pwquality.conf` using `sed` regex replacement.
4. Deploys the custom profile definition `faillock` to `/usr/share/pam-configs/faillock` (with exact tab-indented module hooks).
5. Invokes `pam-auth-update --enable faillock --force` to inject `pam_faillock.so` hooks into the live system PAM stack.

```Bash
sudo bash /vagrant/02-pam/install.sh
```

### Step 2: Verification Test Suite (`test.sh`)

Execute the verification script to validate system compliance and configuration integrity:

```Bash
sudo bash /vagrant/02-pam/test.sh
```

**Expected Output**:

```Plaintext
[*] Running verification suite for module 02-pam...
[*] Checking if libpam-pwquality is installed... [✔] OK
[*] Checking /etc/security/pwquality.conf... [✔] OK
[*] Checking /etc/security/faillock.conf... [✔] OK
[*] Verifying minlen = 14 in pwquality.conf... [✔] OK
[*] Checking if pam-auth-update has faillock enabled... [✔] OK
[*] Checking common-auth for pam_faillock hooks... [✔] OK
--------------------------------------------------
[✔] All PAM verification tests passed successfully!
```

## 🔍 Profile Configuration Rules (`/usr/share/pam-configs/faillock`)

When customizing or debugging the `faillock` profile, adhere strictly to Debian `pam-auth-update` specifications:
1. **Location**: Profiles must reside in `/usr/share/pam-configs/` for `pam-auth-update` discovery.
2. **Tab Indentation**: Module action lines under headers (e.g., `Auth:`) must start with a literal leading tab character (`\t`). Spaces will cause `pam-auth-update` parsing failures.
3. **Fields**: Include standard headers (`Name`, `Default`, `Priority`, `Auth-Type`, `Auth`).

## 🚨 Troubleshooting & Edge Cases

### `minlen` Test Failures

- **Symptom**: `[-] FAILED: minlen is not set to 14.`
- **Cause**: The `/etc/security/pwquality.conf` file was either overwritten by a template missing `minlen` or remained commented out (`# minlen = 14`).
- **Resolution**: Re-run `install.sh`. The built-in `sed` check automatically uncomment or appends `minlen = 14`.

## PAM Profiles Not Registering

- **Symptom**: `grep "pam_faillock.so" /etc/pam.d/common-auth` returns empty.
- **Cause**: The profile file was placed in `/etc/pam-configs/` instead of `/usr/share/pam-configs/` or contains syntax errors.
- **Resolution**: Confirm path `/usr/share/pam-configs/faillock` and verify tab indentation before re-running `sudo pam-auth-update --enable faillock --force`.
