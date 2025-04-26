docker rm -f wireguard-proxy
docker image rm wireguard-proxy
docker build -t wireguard-proxy .
docker run -d \
    --name wireguard-proxy \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    --sysctl net.ipv4.conf.all.src_valid_mark=1 \
    --sysctl net.ipv4.ip_forward=1 \
    --privileged \
    -p 8118:8118 \
    -e "DOMAINS_TO_RELAY=youtube.com,api.ipify.org" \
    -v "/mnt2/homes/docker/Youtube-Adblock-Proxy/surfshark_albania.conf:/etc/wireguard/wg0.conf" \
    wireguard-proxy
