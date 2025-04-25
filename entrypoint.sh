#!/bin/bash
set -e

# Start WireGuard
wg-quick up wg0

# Create a routing table for marked packets
ip rule add fwmark 1 table 100
ip route add default dev wg0 table 100

# Set up iptables mangle rule
iptables -t mangle -N YOUTUBE || true
iptables -t mangle -A PREROUTING -j YOUTUBE
iptables -t mangle -A YOUTUBE -p tcp -m multiport --dports 80,443 \
    -m string --algo bm --string "youtube.com" -j MARK --set-mark 1

# Start HTTP proxy server (tinyproxy)
/etc/init.d/tinyproxy start

# Keep container running
tail -f /dev/null
