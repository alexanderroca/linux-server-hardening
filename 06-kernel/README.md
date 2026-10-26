# Module 06: Kernel Module & Attack Surface Reduction (`modprobe`)

To minimize the kernel's internal attack surface and mitigate local privilege escalation or container escape vectors, unused legacy filesystems and uncommon network protocols were disabled using the `install /bin/true` suppression method.

---

## 1. Architecture & Security Blacklist Configuration

The security rules are deployed to `/etc/modprobe.d/99-security-blacklist.conf`. By mapping unwanted drivers and protocols to `/bin/true`, the kernel immediately exits successfully without loading the target driver when requested.

### Configuration Rules (`/etc/modprobe.d/99-security-blacklist.conf`)
```plaintext
# --- Disable Unused Filesystems ---
install cramfs /bin/true
install freevxfs /bin/true
install jffs2 /bin/true
install hfs /bin/true
install hfsplus /bin/true
install udf /bin/true
install usb-storage /bin/true

# --- Disable Uncommon Network Protocols ---
install dccp /bin/true
install sctp /bin/true
install rds /bin/true
install tipc /bin/true
```

## 2. Initramfs Optimization & AppArmor Constraints

To bake the module blacklists into early boot and prevent generation stalls:
- **Compression Handling**: Ensures the `zstd` compression package is installed so `update-initramfs` avoids slow single-threaded `gzip` fallbacks that can stall virtualized file systems.
- **AppArmor Profile Adjustment**: Temporarily shifts `busybox` into `complain` mode during RAM filesystem generation to prevent shared library (`libresolv.so.2`) blocking under strict enforcement.

## 3. Execution & Verification

### Run Installation Script

Deploys the blacklist configuration, verifies compression dependencies, and updates the initial RAM filesystem:

```Bash
sudo bash /vagrant/06-kernel/install.sh
```

### Run Automated Verification Suite

Validates configuration deployment and checks module mapping redirection:

```Bash
sudo bash /vagrant/06-kernel/test.sh
```

### Manual Verification

Verify that blacklisted modules are successfully intercepted and mapped to `/bin/true`:

```Bash
sudo modprobe -v cramfs
```

*Expected Output*: `install /bin/true`
