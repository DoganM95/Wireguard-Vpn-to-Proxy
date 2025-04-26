#!/bin/bash
set -e

# Mark to identify rules we create
MARK="vpnroute"

# Clear and recreate mangle chain
iptables -t mangle -N RELAY || true

while true; do
    echo "[dns-update] Updating IP rules..."

    # Read domain list from environment
    IFS=',' read -ra DOMAINS <<<"$DOMAINS_TO_RELAY"

    # Clear old ip rules managed by this script
    ip rule show | grep "$MARK" | while read -r rule; do
        prio=$(echo "$rule" | awk '{print $1}')
        ip rule del pref "$prio"
    done

    # Clear old mangle rules (optional: recreate clean)
    iptables -t mangle -F RELAY

    for domain in "${DOMAINS[@]}"; do
        domain=$(echo "$domain" | xargs) # trim whitespace
        if [ -z "$domain" ]; then
            continue
        fi

        # Resolve domain to IPs
        IPs=$(dig +short "$domain" A | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')

        for ip in $IPs; do
            # Add IP routing rule
            ip rule add to "$ip" table 100 pref 10000 fwmark 1 comment "$MARK"
            echo "[dns-update] Routing $domain ($ip) through VPN."

            # Mark packets to these IPs
            iptables -t mangle -A RELAY -d "$ip" -j MARK --set-mark 1
        done
    done

    sleep 30
done
