FROM alpine:latest

# Install necessary packages
RUN apk add --no-cache wireguard-tools iproute2 privoxy bash curl

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8118

ENTRYPOINT ["/entrypoint.sh"]
