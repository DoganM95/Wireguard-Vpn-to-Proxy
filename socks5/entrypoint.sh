#!/bin/bash
set -e

# Bring down old wg0 if it already exists
if ip link show wg0 >/dev/null 2>&1; then
    echo "wg0 already exists, bringing it down first..."
    wg-quick down wg0
fi

# Start WireGuard
wg-quick up wg0

# Fix: bypass VPN for proxy traffic (3proxy runs as nobody)
PROXY_UID=$(id -u nobody)
ip rule add from all uidrange ${PROXY_UID}-${PROXY_UID} lookup main

# Create a routing table for packets marked with fwmark 1
ip rule add fwmark 1 table 100
ip route add default dev wg0 table 100

# Direct specific destination IPs over VPN (Albania)
ip rule add to 104.26.13.205 table 100 # api.ipify.org
ip rule add to 172.67.74.152 table 100
ip rule add to 104.26.12.205 table 100

ip rule add to 172.217.0.0/16 table 100 # Google/Youtube IPs
ip rule add to 142.250.0.0/15 table 100 # Google Cloud IPs

# Start 3proxy server
3proxy /etc/3proxy/3proxy.cfg

# Keep container alive
tail -f /dev/null
