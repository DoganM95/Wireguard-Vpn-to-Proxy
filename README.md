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
* Gets a new IP address with every container restart, if provider is a VPN hoster
* Container restarts are very fast

## Setup (individual proxies)

### Prerequisites:

1. Obtain a WireGuard configuration file from your VPN provider (Surfshark, ExpressVPN, etc.)
2. Save it on the host machine for Docker volume binding

### Run a proxy container (whitelist mode aka split-tunnelled)

The split-tunnelled image `wireguard-vpn-proxy-st` only routes domains defined using the env var `DOMAINS_TO_RELAY` through the vpn tunnel.
Any other traffic is routed directly, so the host only acts like bridge, but does not alter the trafic.

**Note:** The container requires `--privileged` and a Linux host to function correctly.

```bash
docker run -d \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    --device /dev/net/tun \
    -e "DNS1=94.140.14.14" \
    -e "DOMAINS_TO_RELAY=youtube.com,api.ipify.org,whatismyipaddress.com" \
    --name doganm95-wireguard-vpn-proxy-split-tunnelled \
    --privileged \
    --pull always \
    --restart unless-stopped \
    -p 8120:8118 \
    -v "/path/to/any_wireguard.conf:/home/wg0.conf:ro" \
    ghcr.io/doganm95/wireguard-vpn-proxy-st:latest
```

**Parameters:**

* `-v "/path/to/wg0.conf:/etc/wireguard/wg0.conf"` — WireGuard configuration file
* `-e "DOMAINS_TO_RELAY=..."` — Comma-separated list of domains to route via VPN
* `-p 8120:8118` — Proxy port

#### Test the Proxy

From the host:

```bash
# Should return the VPN's IP
curl -x http://localhost:8120 https://api.ipify.org  

# Should return the host's real IP
curl -x http://localhost:8120 https://api.seeip.org
```

Both commands returning expected results confirms correct operation.

### Run a proxy container (full proxy)

The general image `wireguard-vpn-proxy` routes all traffic through the vpn tunnel. 

```bash
docker run -d \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    --device /dev/net/tun \
    -e "DNS1=94.140.14.14" \
    --name doganm95-wireguard-vpn-proxy \
    --privileged \
    --pull always \
    --restart unless-stopped \
    -p 8120:8118 \
    -v "/path/to/any_wireguard.conf:/home/wg0.conf:ro" \
    ghcr.io/doganm95/wireguard-vpn-proxy:latest
```

## Setup (multiple proxies)

This section shows how to create many individual proxy containers (children) and a main proxy routing container (parent), 
so that the parent can be used as a proxy server in any client and does the routing of which domain goes through which proxy.

For this, sing-box is used as the parent container, which can be set up like this:

Create a config file, named `config.json` with the following working example content:

```json
{
  "log": {
    "disabled": false,
    "level": "trace",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "local",
        "address": "94.140.14.14",
        "strategy": "ipv4_only",
        "detour": "direct-out"
      }
    ]
  },
  "inbounds": [
    {
      "type": "mixed",
      "tag": "mixed-in",
      "listen": "0.0.0.0",
      "listen_port": 8118
    }
  ],
  "outbounds": [
    {
      "type": "http",
      "tag": "proxy-A",
      "server": "172.17.0.1",
      "server_port": 8120
    },
    {
      "type": "http",
      "tag": "proxy-B",
      "server": "172.17.0.1",
      "server_port": 8121
    },
    {
      "type": "direct",
      "tag": "direct-out"
    }
  ],
  "route": {
    "rules": [
      {
        "inbound": [
          "mixed-in"
        ],
        "domain_suffix": [
          "whatismyipaddress.com"
        ],
        "outbound": "proxy-A"
      },
      {
        "inbound": [
          "mixed-in"
        ],
        "domain_suffix": [
          "showmyip.com"
        ],
        "outbound": "proxy-B"
      }
    ],
    "final": "direct-out"
  }
}
```

Notes:

- `dns.servers[0].address` defines dns server to use (here adguard to block any ads by dns)
- `outbounds.server` defines the ip of the proxy containers host (you can get this using `docker inspect some-proxy-container` and checking its network section), `host.docker.internal` does not work in this case.
- `route.rules` defines objects with routing configurations. Here <whatmipaddress.com> will show the ip of proxy-A, <showmyip.com> the ip of proxy-B and any other website will show your real IP, expand as needed.

When the config is created and saved, run the sing-box container like this (adjust if needed).  
The config file must be stored in `/path/to/Singbox/` in this example.

```bash
docker run -d \
  --add-host=host.docker.internal:host-gateway \
  --name sagernet-singbox \
  --pull always \
  -p 6666:8118 \
  --restart unless-stopped \
  -v "/path/to/Singbox/:/etc/sing-box/" \
  ghcr.io/sagernet/sing-box \
  -D /var/lib/sing-box \
  -C /etc/sing-box/ run
```

The sing-box container can now be used as the main proxy and will do all the domain based routing through the defind proxies as per `config.json`. See below how to use it in clients.

### Client Setup

Configure your device’s network settings:

* **Proxy IP:** LAN IP of the Docker host (e.g., `192.168.0.115`)
* **Proxy Port:** Port exposed by the container (e.g., `8120` for single container, or `6666` to use sing-box (multi proxy mode))

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

## Useful commands

Restart all containers that have this string in their name (gets new ipv4 per container)
```shell
docker ps -q --filter "name=proxy" | xargs -r docker restart
```
