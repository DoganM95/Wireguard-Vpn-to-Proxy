#!/bin/bash
set -e

# Bring down old wg0 if it already exists
if ip link show wg0 >/dev/null 2>&1; then
    echo "wg0 already exists, bringing it down first..."
    wg-quick down wg0
fi

# Start WireGuard
wg-quick up wg0

# Fix: bypass VPN for proxy process
PROXY_UID=$(id -u proxy) || PROXY_UID=$(id -u proxyuser) || PROXY_UID=$(id -u nobody)
ip rule add from all uidrange ${PROXY_UID}-${PROXY_UID} lookup main

# Setup VPN routing table
ip rule add fwmark 1 table 100
ip route add default dev wg0 table 100

# Create mangle chain for relay marking
iptables -t mangle -N RELAY || true
iptables -t mangle -A PREROUTING -j RELAY

# Start dynamic DNS updater
/dns-update.sh &

# Start Squid
squid -N -f /etc/squid/squid.conf

# Keep container alive
tail -f /dev/null
