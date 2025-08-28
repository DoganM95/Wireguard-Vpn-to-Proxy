#!/bin/bash
set -e

MARK="vpnroute"
VPN_TABLE=100
CHAIN="RELAY"

# Ensure mangle chain exists
iptables -t mangle -N $CHAIN 2>/dev/null || true

while true; do
    echo "[dns-update] Updating IP rules..."

    if [ -z "$DOMAINS_TO_RELAY" ] || [ "$DOMAINS_TO_RELAY" = "*" ]; then
        echo "[dns-update] DOMAINS_TO_RELAY is unset or '*', routing ALL traffic through VPN."
        # Flush old chain to avoid stale domain-specific rules
        iptables -t mangle -F $CHAIN 2>/dev/null || true

        # Mark everything
        iptables -t mangle -C $CHAIN -j MARK --set-mark 1 2>/dev/null || \
            iptables -t mangle -A $CHAIN -j MARK --set-mark 1

        # Ensure global ip rule exists
        ip rule list | grep -q "fwmark 1 lookup $VPN_TABLE" || \
            ip rule add fwmark 1 table $VPN_TABLE pref 10000 comment "$MARK"

        sleep 30
        continue
    fi

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
