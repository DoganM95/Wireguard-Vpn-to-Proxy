FROM alpine:latest

# Install required packages
RUN apk add --no-cache wireguard-tools iptables privoxy bash curl

# Minimal Privoxy configuration
RUN printf "listen-address 0.0.0.0:8118\n\
    permit-access 0.0.0.0/0\n\
    logfile /dev/stdout\n\
    forward / .\n" > /etc/privoxy/config

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8118

ENTRYPOINT ["/entrypoint.sh"]
