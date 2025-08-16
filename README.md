# Intro

Transforms any WireGuard configuration file into a Docker container that serves a VPN connection as an HTTP/HTTPS proxy. In other words, it acts as a **VPN-to-proxy adapter**. The provided WireGuard configuration can originate from any host—home, business, or VPN provider.

## Use Cases

### Block Ads on YouTube

Many devices (e.g., PlayStation, smart TVs) cannot run a VPN client directly but allow proxy configuration. By routing YouTube traffic through a VPN via this proxy, you can significantly reduce ads. Recommended proxy locations for minimal ads include:

* Albania
* Moldova
* Myanmar

### Access Netflix from Anywhere

Traveling or using devices without VPN support? Connect “dumb” devices to your home WireGuard server through this proxy to access geo-restricted content and maintain your usual streaming experience.

### Quick Downloads & Region Testing

Download files or test region-restricted services quickly without exposing your real IP. Traffic not routed through the VPN continues using your native IP for optimal speed.

## Features

* Lightweight Docker image (\~30 MB)
* Based on **Privoxy**
* **Split tunneling:** route only whitelisted domains through the VPN; all other traffic uses your real IP for performance
* Automatic periodic domain IP updates to maintain correct VPN routing

## Setup

### Prerequisites

1. Obtain a WireGuard configuration file from your VPN provider (Surfshark, ExpressVPN, etc.)
2. Save it on the host machine for Docker volume binding

### Docker Server Setup

#### Run the Container

**Note:** The container requires `--privileged` and a Linux host to function correctly.

```bash
docker run -d \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    --device /dev/net/tun \
    -e "DNS1=94.140.14.14" \
    -e "DOMAINS_TO_RELAY=youtube.com,api.ipify.org,whatismyipaddress.com" \
    --name doganm95-wireguard-vpn-proxy \
    --privileged \
    --pull always \
    --restart always \
    -p 8118:8118 \
    -v "/path/to/surfshark_somelocation.conf:/home/wg0.conf:ro" \
    ghcr.io/doganm95/wireguard-vpn-proxy:latest
```

**Parameters:**

* `-v "/path/to/wg0.conf:/etc/wireguard/wg0.conf"` — WireGuard configuration file
* `-e "DOMAINS_TO_RELAY=..."` — Comma-separated list of domains to route via VPN
* `-p 8118:8118` — Proxy port

#### Test the Proxy

From the host:

```bash
# Should return the VPN's IP
curl -x http://localhost:8118 https://api.ipify.org  

# Should return the host's real IP
curl -x http://localhost:8118 https://api.seeip.org
```

Both commands returning expected results confirms correct operation.

### Client Setup

Configure your device’s network settings:

* **Proxy IP:** LAN IP of the Docker host (e.g., `192.168.0.115`)
* **Proxy Port:** Port exposed by the container (e.g., `8118`)

This allows devices without native VPN support to use the VPN selectively via HTTP/HTTPS proxy.

## Advantages

* Lightweight and portable (\~30 MB Docker image)
* Split-tunnel architecture for optimized performance
* Automatic DNS/IP updates for whitelisted domains
* No installation of a full VPN client required on client devices

## Limitations

* Linux host required (cannot run natively on Windows/macOS)
* Requires `--privileged` for full network routing and TUN device support

## Notes

* Only traffic to whitelisted domains is routed through the VPN; all other traffic continues using your native IP.
* Use the container in trusted environments only; it modifies network routing and firewall rules.
