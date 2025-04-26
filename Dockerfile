FROM alpine:latest

RUN apk add --no-cache wireguard-tools iptables curl

# Use a shell script as entrypoint to avoid issues with argument handling
ENTRYPOINT ["sh", "-c", "wg-quick up wg0 && sleep infinity"]
