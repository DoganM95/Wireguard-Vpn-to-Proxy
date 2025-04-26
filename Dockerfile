FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    wireguard-tools \
    iproute2 \
    openresolv \
    dnsutils \
    curl \
    procps \
    && apt-get clean

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
