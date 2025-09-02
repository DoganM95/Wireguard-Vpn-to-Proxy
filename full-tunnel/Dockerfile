FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    wireguard-tools iproute2 iptables resolvconf privoxy curl bash \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8118

ENTRYPOINT ["/entrypoint.sh"]
