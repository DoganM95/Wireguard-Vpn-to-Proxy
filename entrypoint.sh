#!/bin/bash
set -e

# Bring down old wg0 if it already exists
if ip link show wg0 >/dev/null 2>&1; then
    echo "wg0 already exists, bringing it down first..."
    wg-quick down wg0
fi

# Start WireGuard
wg-quick up wg0

# NAT Masquerade outgoing VPN traffic
iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -A FORWARD -o wg0 -j ACCEPT

# Avoid routing DNS queries into VPN
ip rule add to 8.8.8.8 lookup main

# Fix: bypass VPN for proxy process
PROXY_UID=$(id -u proxy) || PROXY_UID=$(id -u proxyuser) || PROXY_UID=$(id -u nobody)
ip rule add from all uidrange ${PROXY_UID}-${PROXY_UID} lookup main

# Setup split routing
ip rule add fwmark 1 table 100
ip route add default dev wg0 table 100

# Example IPs
ip rule add to 104.26.13.205 table 100
ip rule add to 172.67.74.152 table 100
ip rule add to 104.26.12.205 table 100
ip rule add to 172.217.0.0/16 table 100
ip rule add to 142.250.0.0/15 table 100

# Start Squid
squid -N -f /etc/squid/squid.conf

# Keep container alive
tail -f /dev/null
