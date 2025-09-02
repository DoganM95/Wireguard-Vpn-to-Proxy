#!/bin/bash
set -e

WG_CONF="/etc/wireguard/wg0.conf"
WG_IFACE="wg0"

if [ ! -f "$WG_CONF" ]; then
    echo "WireGuard config not found at $WG_CONF"
    exit 1
fi

echo "Bringing up WireGuard interface..."
ip link add dev $WG_IFACE type wireguard

# Extract keys and allowed IPs
PRIVATE_KEY=$(grep -E '^PrivateKey' $WG_CONF | awk '{print $3}')
PEER_PUBLIC_KEY=$(grep -E '^\[Peer\]' -A 2 $WG_CONF | grep PublicKey | awk '{print $3}')
ALLOWED_IPS=$(grep -E '^\[Peer\]' -A 2 $WG_CONF | grep AllowedIPs | awk '{print $3}')
ENDPOINT=$(grep -E '^\[Peer\]' -A 2 $WG_CONF | grep Endpoint | awk '{print $3}')

# Set the interface private key
wg set $WG_IFACE private-key <(echo $PRIVATE_KEY)

# Add peer
wg set $WG_IFACE peer $PEER_PUBLIC_KEY allowed-ips $ALLOWED_IPS endpoint $ENDPOINT

# Manually configure IP from [Interface] Address
WG_IP=$(grep '^Address' $WG_CONF | awk '{print $3}')
ip addr add $WG_IP dev $WG_IFACE

# Bring interface up
ip link set up dev $WG_IFACE

# Configure NAT
iptables -t nat -A POSTROUTING -o $WG_IFACE -j MASQUERADE
iptables -A FORWARD -i $WG_IFACE -j ACCEPT
iptables -A FORWARD -o $WG_IFACE -j ACCEPT

# Start minimal HTTP-only Privoxy
cat > /etc/privoxy/config <<EOF
listen-address 0.0.0.0:8118
EOF

echo "Starting Privoxy..."
privoxy --no-daemon /etc/privoxy/config
