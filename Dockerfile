FROM alpine:latest

RUN apk add --no-cache wireguard-tools iptables curl openresolv

ENTRYPOINT ["sh", "-c", "wg-quick up wg0 && sleep infinity"]
