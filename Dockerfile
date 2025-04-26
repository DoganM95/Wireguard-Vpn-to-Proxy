FROM alpine:latest

RUN apk add --no-cache wireguard-tools iptables curl openresolv privoxy

# Privoxy config: listens externally and allows HTTP+HTTPS CONNECT requests
RUN echo 'listen-address 0.0.0.0:8118' > /etc/privoxy/config && \
    echo 'forward / .' >> /etc/privoxy/config && \
    echo 'accept-intercepted-requests 1' >> /etc/privoxy/config && \
    echo 'tunnel-all-connects 1' >> /etc/privoxy/config

ENTRYPOINT ["sh", "-c", "wg-quick up wg0 && privoxy --no-daemon /etc/privoxy/config"]
