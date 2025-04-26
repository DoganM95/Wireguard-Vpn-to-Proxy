#!/bin/sh
# fatal if wg fails
wg-quick up wg0 || {
    echo "wg-quick failed, aborting"
    exit 1
}

# ensure vpn table exists
grep -q '^200 vpn' /etc/iproute2/rt_tables || cat >>/etc/iproute2/rt_tables <<-EOF
200     vpn
EOF

# point vpn→wg0 (ignore errors)
ip route add default dev wg0 table vpn 2>/dev/null || true

# build rules for each domain (IPv4 only)
for domain in $(echo "$DOMAINS_TO_RELAY" | tr ',' ' '); do
    echo "Resolving $domain..."
    for ip in $(getent hosts "$domain" |
        awk '{print $1}' |
        grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'); do
        ip rule add to "${ip}/32" table vpn priority 100 2>/dev/null || true
    done
done

# fallback everything else via main
ip rule add lookup main priority 32766 2>/dev/null || true

# NAT & forwarding
iptables -t nat -C POSTROUTING -o wg0 -j MASQUERADE 2>/dev/null ||
    iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
iptables -C FORWARD -i eth0 -o wg0 -j ACCEPT 2>/dev/null ||
    iptables -A FORWARD -i eth0 -o wg0 -j ACCEPT
iptables -C FORWARD -i wg0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null ||
    iptables -A FORWARD -i wg0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

# finally start Privoxy
echo "Starting Privoxy…"
exec privoxy --no-daemon /etc/privoxy/config
