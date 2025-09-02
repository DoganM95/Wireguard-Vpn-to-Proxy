#!/bin/bash
set -e

WG_CONF="/etc/wireguard/wg0.conf"

if [ ! -f "$WG_CONF" ]; then
    echo "WireGuard config not found at $WG_CONF"
    exit 1
fi

echo "Starting WireGuard..."
# Bring up WireGuard via wg-quick (resolvconf + iptables now installed)
wg-quick up "$WG_CONF"

# Wait a moment to ensure interface is up
sleep 2

# Configure Privoxy
echo "Starting Privoxy..."
cat > /etc/privoxy/config <<EOF
listen-address 0.0.0.0:8118
EOF

privoxy --no-daemon /etc/privoxy/config
