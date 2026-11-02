# Debian Linux Hardening Toolkit

An automated, modular hardening framework designed to secure fresh Debian installations to production-grade security standards.

## 🛡️ Included Modules
- **01-ssh:** Hardened SSH configuration (custom port 2222, key-based authentication, root login disabled).
- **02-pam:** Strict password quality policies (`libpam-pwquality`) and brute-force lockout protection (`pam_faillock`).
- **03-firewall:** Stateful packet filtering rules implemented via `nftables` (drop-all default baseline).
- **04-intrusion:** Intrusion prevention with `Fail2ban` and daily file integrity monitoring with `AIDE` (noise-reduced).
- **05-audit:** Immutable kernel and system event auditing via `auditd` with identity and privileged action watches.
- **06-kernel:** Attack surface reduction via `modprobe` blacklisting of legacy filesystems and uncommon network protocols, with AppArmor profile constraint handling and optimized `zstd` initramfs generation.
- **07-updates:** Automated, unattended security patch management (`unattended-upgrades`) and rigorous `sysctl` kernel-level hardening.

*(Note: Mandatory Access Control via AppArmor is active out-of-the-box on Debian 13 and its profile constraints are handled directly within Module 06.)*

## 🚀 Quick Start
Clone this repository directly onto a freshly installed Debian server, run the master script with root privileges, and verify your remote access before disconnecting:

```Bash
git clone https://github.com/alexanderroca/linux-server-hardening.git
cd linux-server-hardening
sudo bash master.sh
```

The master script automatically loops through all 7 modules with real-time progress indicators, executing each module's `install.sh` script followed by its automated verification `test.sh` suite.
