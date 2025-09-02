#!/bin/bash
set -e

WG_CONF="/etc/wireguard/wg0.conf"
WG_IFACE="wg0"

if [ ! -f "$WG_CONF" ]; then
    echo "WireGuard config not found at $WG_CONF"
    exit 1
fi

echo "Bringing up WireGuard..."
ip link add dev $WG_IFACE type wireguard
WG_PRIVATE_KEY=$(grep '^PrivateKey' $WG_CONF | awk '{print $3}')
PEER_PUBLIC_KEY=$(grep '^PublicKey' $WG_CONF | awk '{print $3}')
PEER_ENDPOINT=$(grep '^Endpoint' $WG_CONF | awk '{print $3}')
ALLOWED_IPS=$(grep '^AllowedIPs' $WG_CONF | awk '{print $3}')
WG_ADDRESS=$(grep '^Address' $WG_CONF | awk '{print $3}')

wg set $WG_IFACE private-key <(echo $WG_PRIVATE_KEY)
wg set $WG_IFACE peer $PEER_PUBLIC_KEY endpoint $PEER_ENDPOINT allowed-ips $ALLOWED_IPS
ip addr add $WG_ADDRESS dev $WG_IFACE
ip link set up dev $WG_IFACE

# Enable NAT so traffic goes through WireGuard
iptables -t nat -A POSTROUTING -o $WG_IFACE -j MASQUERADE
iptables -A FORWARD -i $WG_IFACE -j ACCEPT
iptables -A FORWARD -o $WG_IFACE -j ACCEPT

# Create minimal Privoxy config
cat > /etc/privoxy/config <<EOF
listen-address 0.0.0.0:8118
EOF

echo "Starting Privoxy..."
exec privoxy --no-daemon /etc/privoxy/config
