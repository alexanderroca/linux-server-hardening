# Debian Linux Hardening Toolkit

An automated, modular hardening framework designed to secure fresh Debian installations to production-grade security standards.

## 🛡️ Included Modules
* **01-ssh:** Hardened SSH configuration and robust cryptography settings.
* **02-pam:** Strict password quality policies (`pam_pwquality`) and brute-force lockout protection (`pam_faillock`).
* **03-firewall:** Advanced packet filtering rules implemented via `nftables`.
* **04-intrusion:** Intrusion prevention with `Fail2ban` and file integrity monitoring with `AIDE`.
* **05-audit:** Comprehensive kernel and system event auditing via `Auditd`.
* **06-kernel:** Restricted kernel module loading (`modprobe`) and secure `/dev/shm` mounting.
* **07-updates:** Automated, unattended security patch management.
* **08-apparmor:** Mandatory Access Control (MAC) enforcement using AppArmor profiles.

## 🚀 Quick Start
Clone this repository directly onto a freshly installed Debian server, run the master script with root privileges, and verify your remote access before disconnecting:

```Bash
git clone <your-repository-url>
cd linux-server-hardening
sudo ./master.sh
```