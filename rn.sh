docker image rm wireguard-proxy
docker build -t wireguard-proxy .
docker run -d \
    --name wireguard-proxy \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    --cap-add=SYS_ADMIN \
    --device /dev/net/tun \
    --privileged \
    -e "/mnt2/homes/docker/YT-Adblock-Proxy/surfshark_albania.conf:/etc/wireguard/wg0.conf" \
    -p 1080:1080 \
    wireguard-proxy
