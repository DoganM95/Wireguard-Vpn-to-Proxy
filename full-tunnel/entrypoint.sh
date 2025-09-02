#!/bin/bash

set -e

# Start WireGuard VPN
wg-quick up /etc/wireguard/wg0.conf

# Start Privoxy in foreground
exec privoxy --no-daemon /etc/privoxy/config