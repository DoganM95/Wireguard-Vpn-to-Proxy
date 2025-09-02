#!/bin/bash
set -e

WG_CONF="/etc/wireguard/wg0.conf"
WG_IFACE="wg0"

# Check if config exists
if [ ! -f "$WG_CONF" ]; then
    echo "WireGuard config not found at $WG_CONF"
    exit 1
fi

# Bring up WireGuard interface manually
echo "Bringing up WireGuard interface..."
ip link add dev $WG_IFACE type wireguard
wg setconf $WG_IFACE $WG_CONF
WG_IP=$(grep Address $WG_CONF | awk '{print $3}' | cut -d/ -f1)
ip addr add $WG_IP dev $WG_IFACE
ip link set up dev $WG_IFACE

# Set default route through WireGuard
PEER_ENDPOINT=$(grep Endpoint $WG_CONF | awk '{print $3}' | cut -d: -f1)
PEER_PORT=$(grep Endpoint $WG_CONF | awk '{print $3}' | cut -d: -f2)
WG_PUBLIC_KEY=$(grep PublicKey $WG_CONF | awk '{print $3}')
wg set $WG_IFACE peer $WG_PUBLIC_KEY endpoint $PEER_ENDPOINT:$PEER_PORT allowed-ips 0.0.0.0/0

# Enable NAT so container traffic goes through WireGuard
echo "Configuring NAT..."
iptables -t nat -A POSTROUTING -o $WG_IFACE -j MASQUERADE
iptables -A FORWARD -i $WG_IFACE -j ACCEPT
iptables -A FORWARD -o $WG_IFACE -j ACCEPT

# Configure minimal Privoxy
cat > /etc/privoxy/config <<EOF
listen-address 0.0.0.0:8118
EOF

echo "Starting Privoxy..."
privoxy --no-daemon /etc/privoxy/config
