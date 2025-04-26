FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    privoxy \
    wireguard-tools \
    iproute2 \
    iptables \
    nftables \
    dnsutils \
    openresolv \
    procps \
    curl \
    && apt-get clean

COPY ./entrypoint.sh /entrypoint.sh
COPY ./privoxy-config /etc/privoxy/config
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
