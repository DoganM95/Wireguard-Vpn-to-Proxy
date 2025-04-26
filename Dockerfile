FROM alpine:latest

RUN apk add --no-cache wireguard-tools iptables

# Ensure wireguard module is loaded on host; alpine will use it
ENTRYPOINT ["wg-quick", "up", "/etc/wireguard/wg0.conf"]

# Keep the container alive
CMD ["sleep", "infinity"]
