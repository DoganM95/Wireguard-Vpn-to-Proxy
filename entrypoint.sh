#!/bin/bash
set -e

# Bring down old wg0 if it already exists (important for restarts!)
if ip link show wg0 >/dev/null 2>&1; then
    echo "wg0 already exists, bringing it down first..."
    wg-quick down wg0
fi

# Start WireGuard fresh
wg-quick up wg0

# Fix: bypass VPN for proxy traffic (Tinyproxy runs as nobody)
PROXY_UID=$(id -u nobody)
ip rule add from all uidrange ${PROXY_UID}-${PROXY_UID} lookup main

# Create a routing table for marked packets
ip rule add fwmark 1 table 100
ip route add default dev wg0 table 100

# Direct api.ipify.org IPs over VPN (IP-based split routing)
ip rule add to 104.26.13.205 table 100
ip rule add to 172.67.74.152 table 100
ip rule add to 104.26.12.205 table 100

ip rule add to 172.217.0.0/16 table 100 # Google/Youtube IPs
ip rule add to 142.250.0.0/15 table 100 # Google Cloud IPs

# Set up iptables mangle rule for VPN routing
iptables -t mangle -N RELAY || true
iptables -t mangle -A PREROUTING -j RELAY

# Mark YouTube HTTPS traffic
iptables -t mangle -A RELAY -p tcp --dport 443 \
    -m string --algo bm --string "youtube.com" -j MARK --set-mark 1

# Mark api.ipify.org HTTPS traffic
iptables -t mangle -A RELAY -p tcp --dport 443 \
    -m string --algo bm --string "api.ipify.org" -j MARK --set-mark 1

# Start Tinyproxy
/etc/init.d/tinyproxy start

# Keep container alive
tail -f /dev/null
