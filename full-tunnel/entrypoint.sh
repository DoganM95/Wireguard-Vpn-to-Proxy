#!/bin/bash
set -e
# Comment out WireGuard startup
# wg-quick up /etc/wireguard/wg0.conf
exec privoxy --no-daemon /etc/privoxy/config