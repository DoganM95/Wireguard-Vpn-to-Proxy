FROM alpine:latest

RUN apk add --no-cache wireguard-tools iptables privoxy bash

# Create directories for configs
RUN mkdir -p /etc/wireguard /etc/privoxy

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8118

ENTRYPOINT ["/entrypoint.sh"]
