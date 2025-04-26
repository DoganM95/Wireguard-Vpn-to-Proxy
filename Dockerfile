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
    wg-quick up wg0 && \
    ip route add 10.0.0.0/24 via $(ip route show default | awk '/default/ {print $3}') dev eth0 && \
    iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE && \
    iptables -A FORWARD -i eth0 -o wg0 -j ACCEPT && \
    iptables -A FORWARD -i wg0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT && \
    privoxy --no-daemon /etc/privoxy/config \
    "]