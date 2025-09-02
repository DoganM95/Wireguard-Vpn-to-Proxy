#!/bin/bash
set -e

WG_CONF="/conf/wg0.conf"

# Check if WireGuard config exists
if [ ! -f "$WG_CONF" ]; then
    echo "WireGuard config not found at $WG_CONF"
    exit 1
fi

# Start WireGuard
echo "Starting WireGuard..."
wg-quick up "$WG_CONF"

# Configure iptables for NAT routing
echo "Enabling NAT..."
WG_IFACE=$(basename "$WG_CONF" .conf)
iptables -t nat -A POSTROUTING -o "$WG_IFACE" -j MASQUERADE
iptables -A FORWARD -i "$WG_IFACE" -j ACCEPT
iptables -A FORWARD -o "$WG_IFACE" -j ACCEPT

# Configure Privoxy to forward traffic through WireGuard
echo "Configuring Privoxy..."
cat > /etc/privoxy/config <<EOF
listen-address 0.0.0.0:8118
forward-socks5t / 127.0.0.1:9050 .
EOF

# Make Privoxy use HTTP (no SOCKS5)
sed -i 's/forward-socks5t/#forward-socks5t/' /etc/privoxy/config

# Start Privoxy
echo "Starting Privoxy..."
privoxy --no-daemon /etc/privoxy/config
