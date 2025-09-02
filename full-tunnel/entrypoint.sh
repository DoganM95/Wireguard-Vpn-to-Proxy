#!/bin/bash
set -e

WG_CONF=/etc/wireguard/wg0.conf
PRIVOXY_CONF=/etc/privoxy/config

if [ ! -f "$WG_CONF" ]; then
    echo "Error: WireGuard config ($WG_CONF) not found. Mount it as a volume."
    exit 1
fi

# Start WireGuard with wg-quick (handles Address, DNS, routing)
wg-quick up wg0

# Minimal Privoxy config (HTTP proxy)
cat > "$PRIVOXY_CONF" <<EOF
listen-address 0.0.0.0:8118
forward-socks5t / 127.0.0.1:0 .
EOF

# Start Privoxy
exec privoxy --no-daemon "$PRIVOXY_CONF"
