FROM alpine:latest

RUN apk add --no-cache wireguard-tools iptables curl openresolv privoxy

# Privoxy minimal HTTP proxy configuration
RUN echo 'listen-address 0.0.0.0:8118' > /etc/privoxy/config && \
    echo 'forward / .' >> /etc/privoxy/config

# Start WireGuard VPN first, then Privoxy HTTP proxy
ENTRYPOINT ["sh", "-c", "wg-quick up wg0 && privoxy --no-daemon /etc/privoxy/config"]
