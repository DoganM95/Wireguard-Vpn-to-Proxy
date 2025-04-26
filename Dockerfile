FROM alpine:latest

RUN apk add --no-cache wireguard-tools iptables curl openresolv privoxy

# Privoxy listens on port 8118 by default
RUN sed -i 's/listen-address  localhost:8118/listen-address  0.0.0.0:8118/' /etc/privoxy/config

# Run WireGuard VPN, then Privoxy
ENTRYPOINT ["sh", "-c", "wg-quick up wg0 && privoxy --no-daemon /etc/privoxy/config"]
