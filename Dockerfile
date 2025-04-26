FROM alpine:latest

RUN apk add --no-cache wireguard-tools iptables curl openresolv privoxy

# Privoxy config without 'tunnel-all-connects'
RUN echo 'listen-address  0.0.0.0:8118' > /etc/privoxy/config && \
    echo 'forward / .' >> /etc/privoxy/config && \
    echo 'accept-intercepted-requests 1' >> /etc/privoxy/config && \
    echo 'enable-remote-toggle 1' >> /etc/privoxy/config && \
    echo 'enable-edit-actions 1' >> /etc/privoxy/config && \
    echo 'permit-access 0.0.0.0/0' >> /etc/privoxy/config

ENTRYPOINT ["sh", "-c", "\
    GATEWAY=$(ip route show default | awk '/default/ {print $3}') && \
    wg-quick up wg0 && \
    ip rule del table 51820 || true && \
    ip rule del table main suppress_prefixlength 0 || true && \
    echo 'nameserver 8.8.8.8' > /etc/resolv.conf && \
    ip route add 104.16.0.0/12 dev wg0 table 100 && \
    ip route add 172.64.0.0/13 dev wg0 table 100 && \
    ip route add 131.0.72.0/22 dev wg0 table 100 && \
    ip rule add to 104.16.0.0/12 lookup 100 && \
    ip rule add to 172.64.0.0/13 lookup 100 && \
    ip rule add to 131.0.72.0/22 lookup 100 && \
    ip rule add from all lookup main && \
    ip route add 10.0.0.0/24 via $GATEWAY dev eth0 && \
    privoxy --no-daemon /etc/privoxy/config \
    "]
