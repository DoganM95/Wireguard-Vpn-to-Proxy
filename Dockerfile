FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    wireguard-tools \
    iproute2 \
    iptables \
    nftables \
    dnsutils \
    dante-server \
    tinyproxy \
    openresolv \
    procps \
    && apt-get clean

RUN echo "User nobody" > /etc/tinyproxy/tinyproxy.conf && \
    echo "Group nogroup" >> /etc/tinyproxy/tinyproxy.conf && \
    echo "Port 1080" >> /etc/tinyproxy/tinyproxy.conf && \
    echo "Listen 0.0.0.0" >> /etc/tinyproxy/tinyproxy.conf && \
    echo "Timeout 600" >> /etc/tinyproxy/tinyproxy.conf && \
    echo "DefaultErrorFile \"/usr/share/tinyproxy/default.html\"" >> /etc/tinyproxy/tinyproxy.conf && \
    echo "StatHost \"tinyproxy.stats\"" >> /etc/tinyproxy/tinyproxy.conf && \
    echo "Logfile \"/var/log/tinyproxy/tinyproxy.log\"" >> /etc/tinyproxy/tinyproxy.conf && \
    echo "LogLevel Info" >> /etc/tinyproxy/tinyproxy.conf && \
    echo "MaxClients 100" >> /etc/tinyproxy/tinyproxy.conf && \
    echo "MinSpareServers 5" >> /etc/tinyproxy/tinyproxy.conf && \
    echo "MaxSpareServers 20" >> /etc/tinyproxy/tinyproxy.conf && \
    echo "StartServers 10" >> /etc/tinyproxy/tinyproxy.conf && \
    echo "Allow 10.0.0.0/8" >> /etc/tinyproxy/tinyproxy.conf && \
    echo "Allow 192.168.0.0/16" >> /etc/tinyproxy/tinyproxy.conf && \
    echo "ConnectPort 443" >> /etc/tinyproxy/tinyproxy.conf && \
    echo "ConnectPort 80" >> /etc/tinyproxy/tinyproxy.conf

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]