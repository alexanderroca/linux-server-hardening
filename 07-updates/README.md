# Automatic Updates & Kernel Tuning

## Automated Security Updates (`unattended-upgrades`)

Zero-day vulnerabilities and newly discovered exploits emerge constantly. Relying on manual updates leaves a server exposed during the window between a patch release and an administrator logging in.

1. Install the `unattended-upgrades` package via the Debian package manager:

```Bash
sudo apt install unattended-upgrades -y
```

2. Configure the package to automatically download and apply security updates using the low-priority configuration utility:

```Bash
sudo dpkg-reconfigure -plow unattended-upgrades
```

## Kernel-Level Hardening (`sysctl`)

The default Linux kernel prioritizes maximum compatibility and out-of-the-box networking flexibility over security. By tuning `sysctl` parameters, we enforce stricter compliance and block entire classes of network and local host attacks.

1. Open your security configuration file:

```Bash
sudo vim /etc/sysctl.d/99-security.conf
```

2. Append the production-grade network and memory protection parameters:

```Plaintext
# --- Network Stack Hardening ---
# Enable Reverse Path Filtering (drops packets with spoofed source addresses)
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Disable IP source routing (prevents attackers from specifying packet routing paths)
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# Ignore ICMP redirect messages (prevents man-in-the-middle route manipulation)
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Ignore send redirects
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Ignore ICMP broadcast echoes (prevents smurf amplifier attacks)
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Log martian packets (packets with impossible source addresses)
net.ipv4.conf.all.log_martians = 1

# --- Kernel Memory Protections ---
# Restrict kernel symbol addresses exposure (mitigates local privilege escalation info leaks)
kernel.kptr_restrict = 2

# Restrict access to performance events
kernel.perf_event_paranoid = 3

# --- Filesystem Hardening ---
# Protect against TOCTOU races on hard and symbolic links
fs.protected_hardlinks = 1
fs.protected_symlinks = 1

# Disable core dumps for setuid programs to prevent leaking sensitive memory
fs.suid_dumpable = 0
```

3. Apply the changes immediately to the running kernel:

```Bash
sudo sysctl --system
```

## Verification

1. Verify that the system successfully enforces Reverse Path Filtering:

```Bash
sysctl net.ipv4.conf.all.rp_filter
```

*Expected Output*: `net.ipv4.conf.all.rp_filter = 1`

2. Verify that symbolic link protections are active:

```Bash
sysctl fs.protected_symlinks
```
