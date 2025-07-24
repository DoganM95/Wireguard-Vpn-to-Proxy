# Intro

This app turns any wireshark conf file into a docker container, that serves the vpn connection as a http/https proxy server, in other works: a vpn to http proxy adapter. The provided wireshark configuration file can be from any host, be it your home, business or vpn provider connection. This project in beta phase and only ready for development/testing purposes.

# Use cases

## Block ads on youtube

The proxy adapter comes in handy, if your device has no option to configure a vpn client, but allows you to set a proxy server, e.g. a PlayStation.
Using any of these locations will give you a lot less ads, making youtube almost or fully ad free: 
- Albania
- Moldova
- Myanmar

## Use netflix from anywhere

When you e.g. travel a lot, netflix locks you out as your ip address changes to a foreign one. 
By setting up a wireguard server in your home network, you can connect "dumb" devices (with no vpn client but configurable proxy) to your home's wireguard and enjoy again, what you pay for.

## Quick downloads

If you just want to download q.g. 1 file from a server with pvn, just use a docker run command. 
The file lands on your bound volume and your real ip is kept secret.
Also great for quick testing of region-locks. 

# Features

- Lightweight vpn to proxy adapter available, with a docker image size of 20 MB
- Based on privoxy
- Split tunneling: set a whitelist of hosts, the vpn connection should be used for only, the rest is routed normally with your real ip

# Docker

Run the container using the following command, for now the container needs to run `--privileged`

```shell
docker run -d \
    --name wireguard-proxy \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    --cap-add=SYS_ADMIN \
    --device /dev/net/tun \
    --privileged \
    --pull always \
    --restart always \
    -v "/home/surfshark_albania.conf:/etc/wireguard/wg0.conf" \
    -p 1080:1080 \
    wireguard-proxy
```

- `-v "...:/etc/wireguard/wg0.conf"` wg conf file to mount
