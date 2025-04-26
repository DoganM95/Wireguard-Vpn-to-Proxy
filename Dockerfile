FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    wireguard-tools \
    iproute2 \
    iptables \
    nftables \
    dnsutils \
    3proxy \
    openresolv \
    procps \
    && apt-get clean

RUN echo "nserver 8.8.8.8" > /etc/3proxy/3proxy.cfg && \
    echo "nscache 65536" >> /etc/3proxy/3proxy.cfg && \
    echo "timeouts 1 5 30 60 180 1800 15 60" >> /etc/3proxy/3proxy.cfg && \
    echo "log /dev/null" >> /etc/3proxy/3proxy.cfg && \
    echo "auth none" >> /etc/3proxy/3proxy.cfg && \
    echo "socks -p1080" >> /etc/3proxy/3proxy.cfg


COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
