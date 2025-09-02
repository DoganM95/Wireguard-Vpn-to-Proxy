FROM alpine:latest

# Install WireGuard tools, iptables and Privoxy
RUN apk add --no-cache wireguard-tools iptables privoxy bash curl

# Privoxy config (basic proxy, open to all)
RUN printf "listen-address 0.0.0.0:8118\n\
    permit-access 0.0.0.0/0\n\
    logfile /dev/stdout\n\
    forward / .\n" > /etc/privoxy/config

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
