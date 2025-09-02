#!/bin/bash
# entrypoint.sh
set -euo pipefail
WG_SRC="${WG_SRC:-/home/wg0.conf}"
WG_DST="/etc/wireguard/wg0.conf"
mkdir -p /etc/wireguard
cp "$WG_SRC" "$WG_DST"

# Prefer DNS from wg0.conf; else DNS1/DNS2 env; else Cloudflare
: > /etc/resolv.conf
dns_from_conf="$(awk -F'=' '/^[[:space:]]*DNS[[:space:]]*=/{print $2}' "$WG_DST" | tr -d ' ' | tr ',' ' ')"
if [ -n "$dns_from_conf" ]; then for d in $dns_from_conf; do echo "nameserver $d"; done >> /etc/resolv.conf; elif [ -n "${DNS1:-}" ]; then echo "nameserver $DNS1" >> /etc/resolv.conf; [ -n "${DNS2:-}" ] && echo "nameserver $DNS2" >> /etc/resolv.conf; else echo -e "nameserver 1.1.1.1\nnameserver 1.0.0.1" >> /etc/resolv.conf; fi

sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || true

echo "Starting WireGuard..."
wg-quick up wg0

echo "Waiting for WireGuard handshake..."
for _ in $(seq 1 30); do hs="$(wg show wg0 latest-handshakes | awk '{print $2}')" || hs=""
  if [ -n "$hs" ] && [ "$hs" != "0" ]; then break; fi
  sleep 1
done

echo "Starting Privoxy..."
exec privoxy --no-daemon /etc/privoxy/config
