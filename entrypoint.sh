#!/bin/bash
set -e

# Copy mounted WireGuard config to /etc/wireguard/wg0.conf
WG_SRC="/home/wg0.conf"
WG_DST="/etc/wireguard/wg0.conf"

# Ensure destination directory exists
mkdir -p /etc/wireguard

# Copy the file
cp "$WG_SRC" "$WG_DST"

# Insert "Table = off" after [Interface] if not already present
if ! grep -q '^Table *= *off' "$WG_DST"; then
    # Insert after [Interface] line
    sed -i '/^\[Interface\]/a Table = off' "$WG_DST"
fi

# Ensure VPN routing table exists
grep -q '^200 vpn' /etc/iproute2/rt_tables || echo "200 vpn" >> /etc/iproute2/rt_tables

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

# Ensure VPN table has default route
ip route flush table vpn 2>/dev/null || true
ip route add default dev wg0 table vpn || true

# Force DNS inside container using env vars
if [ -n "$DNS1" ]; then
    echo "nameserver $DNS1" > /etc/resolv.conf
    if [ -n "$DNS2" ]; then
        echo "nameserver $DNS2" >> /etc/resolv.conf
    fi
else
    echo "[ERROR] DNS1 environment variable not set"
    exit 1
fi

# Add rules for whitelisted domains (initial)
if [ -z "$DOMAINS_TO_RELAY" ] || [ "$DOMAINS_TO_RELAY" = "*" ]; then
    echo "Routing ALL traffic through VPN..."
    ip rule add from all lookup vpn priority 100
else
    for domain in $(echo "$DOMAINS_TO_RELAY" | tr ',' ' '); do
        echo "Resolving $domain..."
        ips=$(dig +short A "$domain" @"$DNS1" | sort -u)
        for ip in $ips; do
            echo "Routing $domain ($ip) through VPN"
            ip rule add to "${ip}/32" table vpn priority 100 2>/dev/null || true
        done
    done
    # Send all other traffic via main table (native IP)
    ip rule add lookup main priority 32766 2>/dev/null || true
fi

# Send all other traffic via main table (native IP)
ip rule add lookup main priority 32766 2>/dev/null || true

# NAT for VPN traffic
iptables -t nat -C POSTROUTING -o wg0 -j MASQUERADE 2>/dev/null || \
    iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE

# Forward traffic from container to VPN
iptables -C FORWARD -i wg0 -o wg0 -j ACCEPT 2>/dev/null || \
    iptables -A FORWARD -i wg0 -o wg0 -j ACCEPT
iptables -C FORWARD -i wg0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
    iptables -A FORWARD -i wg0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Show routing for debugging
echo "IP Rules:"
ip rule show
echo "VPN Table:"
ip route show table vpn

# Start Privoxy in foreground (PID 1)
echo "Starting Privoxy..."
exec privoxy --no-daemon /etc/privoxy/config
