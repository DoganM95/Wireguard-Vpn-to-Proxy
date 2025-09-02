FROM alpine:latest

# Install necessary tools
RUN apk add --no-cache wireguard-tools iproute2 iptables privoxy bash curl

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8118

ENTRYPOINT ["/entrypoint.sh"]
