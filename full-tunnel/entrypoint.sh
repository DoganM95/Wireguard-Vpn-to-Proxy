#!/bin/bash
set -e

WG_CONF=/etc/wireguard/wg0.conf
PRIVOXY_CONF=/etc/privoxy/config

# Ensure a WireGuard config is mounted
if [ ! -f "$WG_CONF" ]; then
    echo "Error: WireGuard config ($WG_CONF) not found. Mount it as a volume."
    exit 1
fi

# Start WireGuard interface
ip link add dev wg0 type wireguard
wg setconf wg0 "$WG_CONF"
ip link set wg0 up
# Take first IP from config
WG_IP=$(grep -m1 '^Address' "$WG_CONF" | cut -d'=' -f2 | tr -d ' ')
ip addr add "$WG_IP" dev wg0

# Default route through wg0
ip route add default dev wg0 || true

# Minimal Privoxy config
cat > "$PRIVOXY_CONF" <<EOF
listen-address 0.0.0.0:8118
forward-socks5t / 127.0.0.1:0 .
EOF

# Start Privoxy in foreground
exec privoxy --no-daemon "$PRIVOXY_CONF"
