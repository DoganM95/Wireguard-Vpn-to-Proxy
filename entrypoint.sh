#!/bin/bash
set -e

# Bring down old wg0 if it already exists
if ip link show wg0 >/dev/null 2>&1; then
    echo "wg0 already exists, bringing it down first..."
    wg-quick down wg0
fi

# Start WireGuard
wg-quick up wg0

# NAT outgoing VPN traffic
iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -A FORWARD -o wg0 -j ACCEPT

# Bypass VPN for DNS
ip rule add to 8.8.8.8 lookup main

# Split tunneling rules
PROXY_UID=$(id -u privoxy) || PROXY_UID=$(id -u nobody)
ip rule add from all uidrange ${PROXY_UID}-${PROXY_UID} lookup main

# Setup split VPN routing
ip rule add fwmark 1 table 100
ip route add default dev wg0 table 100

# Example IPs to split tunnel
ip rule add to 104.26.13.205 table 100
ip rule add to 172.67.74.152 table 100
ip rule add to 104.26.12.205 table 100
ip rule add to 172.217.0.0/16 table 100
ip rule add to 142.250.0.0/15 table 100

# Force default route through wg0
ip route replace default dev wg0

# Start Privoxy
privoxy --no-daemon /etc/privoxy/config &

# Keep container alive
tail -f /dev/null
