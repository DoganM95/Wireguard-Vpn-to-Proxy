FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    squid \
    wireguard-tools \
    iproute2 \
    iptables \
    nftables \
    dnsutils \
    openresolv \
    procps \
    && apt-get clean

COPY ./dns-update.sh /dns-update.sh
RUN chmod +x /dns-update.sh

COPY ./squid.conf /etc/squid/squid.conf
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
