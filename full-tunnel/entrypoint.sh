#!/bin/bash
set -e

# Set DNS if provided via environment variables
if [ -n "$DNS1" ]; then
    echo "nameserver $DNS1" > /etc/resolv.conf
fi

# Start WireGuard VPN
wg-quick up /etc/wireguard/wg0.conf

# Start Privoxy in foreground
exec privoxy --no-daemon /etc/privoxy/config