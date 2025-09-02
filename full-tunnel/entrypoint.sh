#!/bin/bash
set -e

echo ">>> Running custom entrypoint.sh"

WG_CONF=/etc/wireguard/wg0.conf
PRIVOXY_CONF=/etc/privoxy/config

if [ ! -f "$WG_CONF" ]; then
    echo "WireGuard config not found at $WG_CONF"
    exit 1
fi

# Bring up WireGuard
wg-quick up wg0

# Force DNS from config
DNS_LINE=$(grep '^DNS' "$WG_CONF" | cut -d= -f2- | tr -d ' ')
if [ -n "$DNS_LINE" ]; then
    echo -n "" > /etc/resolv.conf
    IFS=',' read -ra DNS_SERVERS <<< "$DNS_LINE"
    for dns in "${DNS_SERVERS[@]}"; do
        echo "nameserver $dns" >> /etc/resolv.conf
    done
fi

# Optional: NAT masquerade so *all* traffic goes through WireGuard
iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE

# Minimal HTTP-only Privoxy config
cat > "$PRIVOXY_CONF" <<EOF
listen-address 0.0.0.0:8118
# no forward-socks5t line
EOF

# Start Privoxy
exec privoxy --no-daemon "$PRIVOXY_CONF"
