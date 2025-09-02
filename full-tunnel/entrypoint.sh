#!/bin/bash
set -e

WG_SRC="/home/wg0.conf"
WG_DST="/etc/wireguard/wg0.conf"

mkdir -p /etc/wireguard
cp "$WG_SRC" "$WG_DST"

# Enable IPv4 forwarding
sysctl -w net.ipv4.ip_forward=1

# Bring up WireGuard
echo "Starting WireGuard..."
wg-quick up wg0 || { echo "wg-quick failed"; exit 1; }

echo "Waiting for WireGuard handshake..."
until wg show wg0 latest-handshakes | grep -q -v '^0$'; do
    sleep 1
done
echo "WireGuard connected."

# NAT: route all container traffic through wg0
iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -A FORWARD -o wg0 -j ACCEPT

# Force all traffic (default route) over VPN
ip route del default || true
ip route add default dev wg0

# Start Privoxy in foreground
echo "Starting Privoxy..."
exec privoxy --no-daemon /etc/privoxy/config
