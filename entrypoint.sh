#!/bin/bash
set -e

# Bring down old wg0 if it already exists
if ip link show wg0 >/dev/null 2>&1; then
    echo "wg0 already exists, bringing it down first..."
    wg-quick down wg0
fi

# Start WireGuard
wg-quick up wg0

# Force all traffic through VPN
ip route replace default dev wg0

# Keep container alive
tail -f /dev/null
