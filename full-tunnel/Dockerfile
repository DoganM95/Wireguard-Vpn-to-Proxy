FROM alpine:latest

RUN apk add --no-cache wireguard-tools iptables privoxy bash curl

# Minimal Privoxy config (multiline, readable)
RUN printf "listen-address 0.0.0.0:8118\n\
    permit-access 0.0.0.0/0\n\
    logfile /dev/stdout\n\
    forward / .\n" > /etc/privoxy/config

# Ensure templates folder exists (required by Alpine privoxy)
RUN mkdir -p /etc/privoxy/templates \
    touch /etc/privoxy/templates/no-such-domain \
    echo "Internal error template" > /etc/privoxy/templates/no-such-domain

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8118
ENTRYPOINT ["/entrypoint.sh"]
