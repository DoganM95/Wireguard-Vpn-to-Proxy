#!/bin/bash
set -e

WG_CONF="/conf/wg0.conf"

if [ ! -f "$WG_CONF" ]; then
    echo "WireGuard config not found at $WG_CONF"
    exit 1
fi

echo "Starting WireGuard..."
wg-quick up "$WG_CONF"

echo "Starting Privoxy..."
cat > /etc/privoxy/config <<EOF
listen-address 0.0.0.0:8118
EOF

privoxy --no-daemon /etc/privoxy/config
