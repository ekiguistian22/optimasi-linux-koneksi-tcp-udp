#!/bin/bash
# =====================================================
# DNS Resolver Optimization for BIND9/Named
# Universal Script for Linux (Debian/Ubuntu/CentOS/RHEL/Fedora/Arch)
# =====================================================

echo "[INFO] Applying Linux sysctl tuning for DNS performance..."

# === Kernel Network Tuning ===
sysctl -w net.core.somaxconn=1024
sysctl -w net.ipv4.udp_rmem_min=8192
sysctl -w net.ipv4.udp_wmem_min=8192
sysctl -w net.core.rmem_max=26214400
sysctl -w net.core.wmem_max=26214400
sysctl -w net.ipv4.ip_local_port_range="1024 65535"
sysctl -w net.ipv4.conf.all.accept_source_route=0

# Save settings permanently
cat <<EOF >/etc/sysctl.d/99-dns-tuning.conf
# DNS Tuning (BIND9/Named)
net.core.somaxconn = 1024
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192
net.core.rmem_max = 26214400
net.core.wmem_max = 26214400
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.conf.all.accept_source_route = 0
EOF

# Reload sysctl
sysctl --system

# === Detect OS ===
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    echo "[INFO] Detected OS: $PRETTY_NAME"
else
    OS="unknown"
    echo "[WARN] Could not detect OS version"
fi

# === Restart DNS Service (bind9 or named) ===
if systemctl list-unit-files | grep -q "bind9.service"; then
    systemctl restart bind9
    echo "[INFO] Restarted bind9 service"
elif systemctl list-unit-files | grep -q "named.service"; then
    systemctl restart named
    echo "[INFO] Restarted named service"
else
    echo "[WARN] DNS service not found (bind9/named). Please restart manually."
fi

echo "[INFO] Sysctl tuning applied successfully!"
