FROM alpine:latest

RUN apk add --no-cache wireguard-tools iptables curl openresolv privoxy

RUN mkdir -p /etc/iproute2 && \
    cat > /etc/iproute2/rt_tables <<-EOF
#
# reserved values
#
255     local
254     main
253     default
0       unspec
#
# local
#
EOF

# Privoxy config
RUN echo 'listen-address  0.0.0.0:8118' > /etc/privoxy/config && \
    echo 'forward / .'        >> /etc/privoxy/config && \
    echo 'accept-intercepted-requests 1' >> /etc/privoxy/config && \
    echo 'enable-remote-toggle 1'       >> /etc/privoxy/config && \
    echo 'enable-edit-actions 1'       >> /etc/privoxy/config && \
    echo 'permit-access 0.0.0.0/0'     >> /etc/privoxy/config

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
