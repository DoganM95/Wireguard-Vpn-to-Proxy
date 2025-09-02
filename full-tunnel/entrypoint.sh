#!/bin/bash
set -e

WG_CONF=/etc/wireguard/wg0.conf
PRIVOXY_CONF=/etc/privoxy/config

if [ ! -f "$WG_CONF" ]; then
    echo "WireGuard config not found at $WG_CONF"
    exit 1
fi

# Start WireGuard (wg-quick handles Address, DNS, routing)
wg-quick up wg0

# Simple Privoxy config
cat > "$PRIVOXY_CONF" <<EOF
listen-address 0.0.0.0:8118
forward-socks5t / 127.0.0.1:0 .
EOF

exec privoxy --no-daemon "$PRIVOXY_CONF"
