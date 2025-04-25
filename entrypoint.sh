#!/bin/bash
set -e

# Start WireGuard
wg-quick up wg0

# Fix: bypass VPN for proxy traffic
PROXY_UID=$(id -u nobody)
ip rule add from all uidrange ${PROXY_UID}-${PROXY_UID} lookup main

# Create a routing table for marked packets (YouTube)
ip rule add fwmark 1 table 100
ip route add default dev wg0 table 100

# Set up iptables mangle rule for YouTube
iptables -t mangle -N YOUTUBE || true
iptables -t mangle -A PREROUTING -j YOUTUBE
iptables -t mangle -A YOUTUBE -p tcp -m multiport --dports 80,443 \
    -m string --algo bm --string "youtube.com" -j MARK --set-mark 1

# Start Tinyproxy
/etc/init.d/tinyproxy start

# Keep container alive
tail -f /dev/null
