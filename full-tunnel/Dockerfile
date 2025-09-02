# Dockerfile
FROM alpine:latest
RUN apk add --no-cache wireguard-tools iptables privoxy bash openresolv curl ca-certificates
RUN printf "listen-address 0.0.0.0:8118\npermit-access 0.0.0.0/0\nlogfile /dev/stdout\nforward / .\n" > /etc/privoxy/config
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
