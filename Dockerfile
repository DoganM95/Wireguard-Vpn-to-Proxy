FROM alpine:latest

RUN apk add --no-cache wireguard-tools iptables curl openresolv privoxy

# Create minimal Privoxy config
RUN echo 'listen-address 0.0.0.0:8118' > /etc/privoxy/config && \
    echo 'forward-socks5t / 127.0.0.1:1080 .' >> /etc/privoxy/config

# Start WireGuard VPN, then Privoxy
ENTRYPOINT ["sh", "-c", "wg-quick up wg0 && privoxy --no-daemon /etc/privoxy/config"]
