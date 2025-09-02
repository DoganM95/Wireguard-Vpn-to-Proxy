FROM alpine:latest

RUN apk add --no-cache wireguard-tools iptables privoxy bash openresolv

RUN mkdir -p /etc/wireguard /etc/privoxy
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8118

ENTRYPOINT ["/entrypoint.sh"]
