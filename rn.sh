docker rm -f wireguard-proxy
docker image rm wireguard-proxy
docker build -t wireguard-proxy .

docker run -d \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    --device /dev/net/tun \
    -e "DNS1=94.140.14.14" \
    -e "DOMAINS_TO_RELAY=youtube.com,api.ipify.org,whatismyipaddress.com" \
    --name wireguard-proxy \
    --privileged \
    --restart always \
    -p 8118:8118 \
    -v "/mnt2/homes/docker/Wireguard-Vpn-to-Proxy/surfshark_albania.conf:/home/wg0.conf:ro" \
    wireguard-proxy

# docker run -d \
#     --cap-add=NET_ADMIN \
#     --cap-add=SYS_MODULE \
#     --device /dev/net/tun \
#     -e "DNS1=94.140.14.14" \
#     -e "DOMAINS_TO_RELAY=youtube.com,api.ipify.org,whatismyipaddress.com" \
#     --name wireguard-proxy \
#     --privileged \
#     --pull always \
#     --restart always \
#     -p 8118:8118 \
#     -v "/mnt2/homes/docker/Wireguard-Vpn-to-Proxy/surfshark_albania.conf:/home/wg0.conf:ro" \
#     ghcr.io/doganm95/wireguard-vpn-proxy:latest