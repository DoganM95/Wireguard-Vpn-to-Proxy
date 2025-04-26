FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    unzip \
    curl \
    wireguard-tools \
    iproute2 \
    iptables \
    nftables \
    dnsutils \
    openresolv \
    procps \
    && apt-get clean

# Build 3proxy from source
RUN wget https://github.com/z3APA3A/3proxy/archive/refs/heads/master.zip -O /tmp/3proxy.zip && \
    cd /tmp && \
    unzip 3proxy.zip && \
    cd 3proxy-master && \
    make -f Makefile.Linux && \
    mkdir -p /usr/local/3proxy/bin /usr/local/3proxy/logs /usr/local/3proxy/stat && \
    cp src/3proxy /usr/local/3proxy/bin/ && \
    ln -s /usr/local/3proxy/bin/3proxy /usr/bin/3proxy && \
    rm -rf /tmp/*

RUN echo "nserver 8.8.8.8" > /etc/3proxy/3proxy.cfg && \
    echo "nscache 65536" >> /etc/3proxy/3proxy.cfg && \
    echo "timeouts 1 5 30 60 180 1800 15 60" >> /etc/3proxy/3proxy.cfg && \
    echo "log /dev/null" >> /etc/3proxy/3proxy.cfg && \
    echo "auth none" >> /etc/3proxy/3proxy.cfg && \
    echo "socks -p1080" >> /etc/3proxy/3proxy.cfg


COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
