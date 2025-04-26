FROM alpine:latest

RUN apk add --no-cache wireguard-tools iptables curl openresolv privoxy

# Privoxy configuration supporting HTTPS CONNECT
RUN echo 'listen-address  0.0.0.0:8118' >> /etc/privoxy/config && \
    echo 'forward / .' >> /etc/privoxy/config && \
    echo 'tunnel-all-connects 1' >> /etc/privoxy/config && \
    echo 'accept-intercepted-requests 1' >> /etc/privoxy/config

# Entrypoint: WireGuard, then configure routing, then Privoxy
ENTRYPOINT ["sh", "-c", "\
    wg-quick up wg0 && \
    iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE && \
    iptables -A FORWARD -i eth0 -o wg0 -j ACCEPT && \
    privoxy --no-daemon /etc/privoxy/config\
    "]
