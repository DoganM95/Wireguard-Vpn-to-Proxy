FROM alpine:latest

# Install required packages
RUN apk add --no-cache wireguard-tools iptables privoxy bash bind-tools curl

# Privoxy configuration
RUN printf "listen-address 0.0.0.0:8118\n\
    permit-access 0.0.0.0/0\n\
    enable-remote-toggle 1\n\
    enable-edit-actions 1\n\
    logfile /dev/stdout\n\
    forward / .\n" > /etc/privoxy/config

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]