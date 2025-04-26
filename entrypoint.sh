#!/bin/bash
set -e

# Clean up old wg0 if exists
if ip link show wg0 >/dev/null 2>&1; then
    wg-quick down wg0
fi

# Start WireGuard
wg-quick up wg0

# Bypass VPN for proxy's own process traffic (Tinyproxy or 3proxy)
PROXY_UID=$(id -u nobody)
ip rule add from all uidrange ${PROXY_UID}-${PROXY_UID} lookup main

# Route selected IPs over VPN
ip rule add fwmark 1 table 100
ip route add default dev wg0 table 100

# Allow all other traffic to use main routing table (ISP)
# (Default behavior, nothing else to configure)

# Example: add static VPN routing rules for special IPs
ip rule add to 104.26.13.205 table 100  # api.ipify.org
ip rule add to 172.217.0.0/16 table 100 # YouTube/Google
ip rule add to 142.250.0.0/15 table 100 # More Google

# Start proxy server
/etc/init.d/tinyproxy start

# Keep container running
tail -f /dev/null
