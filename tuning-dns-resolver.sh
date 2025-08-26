#!/bin/bash
# =====================================================
# DNS Resolver Optimization for BIND9/Named
# Universal Script for Linux
# =====================================================

echo "[INFO] Applying Linux sysctl tuning for DNS performance..."

# Tuning kernel network
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

# Restart DNS service (auto-detect bind9 or named)
if systemctl list-unit-files | grep -q "bind9.service"; then
    systemctl restart bind9
    echo "[INFO] Restarted bind9 service"
elif systemctl list-unit-files | grep -q "named.service"; then
    systemctl restart named
    echo "[INFO] Restarted named service"
else
    echo "[WARN] DNS service not found. Please restart manually (bind9/named)."
fi

echo "[INFO] Sysctl tuning applied successfully!"
