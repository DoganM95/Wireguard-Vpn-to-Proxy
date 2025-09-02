FROM alpine:3.18

# Install necessary packages
RUN apk add --no-cache \
    bash \
    wireguard-tools \
    iproute2 \
    iptables \
    openresolv \
    privoxy \
    curl

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8118

ENTRYPOINT ["/entrypoint.sh"]
