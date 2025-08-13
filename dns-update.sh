#!/bin/bash
set -e

MARK="vpnroute"
VPN_TABLE=100
CHAIN="RELAY"

# Ensure mangle chain exists
iptables -t mangle -N $CHAIN 2>/dev/null || true

while true; do
    echo "[dns-update] Updating IP rules..."

    IFS=',' read -ra DOMAINS <<<"$DOMAINS_TO_RELAY"

    # Temporary lists for new rules
    NEW_IP_RULES=()
    NEW_MANGLE_RULES=()

    for domain in "${DOMAINS[@]}"; do
        domain=$(echo "$domain" | xargs)
        [ -z "$domain" ] && continue

        IPs=$(dig +short "$domain" A | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')

        for ip in $IPs; do
            NEW_IP_RULES+=("$ip")
            NEW_MANGLE_RULES+=("$ip")
        done
    done

    # Apply new IP rules first
    for ip in "${NEW_IP_RULES[@]}"; do
        ip rule list | grep -q "$ip" || \
            ip rule add to "$ip" table $VPN_TABLE pref 10000 fwmark 1 comment "$MARK"
    done

    # Flush old mangle rules and apply new ones
    iptables -t mangle -F $CHAIN
    for ip in "${NEW_MANGLE_RULES[@]}"; do
        iptables -t mangle -A $CHAIN -d "$ip" -j MARK --set-mark 1
    done

    # Sleep before next update
    sleep 30
done
