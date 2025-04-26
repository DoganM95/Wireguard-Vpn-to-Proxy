FROM alpine:latest

RUN apk add --no-cache wireguard-tools iptables curl

# Entrypoint to start WireGuard VPN connection
ENTRYPOINT ["wg-quick", "up", "wg0"]

# Keep the container running
CMD ["sleep", "infinity"]
