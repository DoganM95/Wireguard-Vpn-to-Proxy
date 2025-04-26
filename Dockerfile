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
    echo 'nameserver 8.8.8.8' > /etc/resolv.conf && \
    API_IP=$(getent ahostsv4 api.ipify.org | head -n1 | awk '{print $1}') && \
    ip route add ${API_IP}/32 dev wg0 && \
    ip route add 10.0.0.0/24 via $GATEWAY dev eth0 && \
    privoxy --no-daemon /etc/privoxy/config \
    "]
