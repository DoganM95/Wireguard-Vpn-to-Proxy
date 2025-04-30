# Intro

This app turns any wireshark conf file into a docker container, that serves the vpn connection as a http/https proxy server, in other works: a vpn to http proxy adapter. The provided wireshark configuration file can be from any host, be it your home, business or vpn provider connection.

# Use cases

## Block ads on youtube

The proxy adapter comes in handy, if your device has no option to configure a vpn client, but allows you to set a proxy server, e.g. a PlayStation.
Using any of these locations will give you a lot less ads, making youtube almost or fully ad free: 
- Albania
- Moldova
- Myanmar

# Quick downloads

If you just want to download q.g. 1 file from a server with pvn, just use a docker run command. 
The file lands on your bound volume and your real ip is kept secret.
Also great for quick testing of region-locks. 

# Features

- Lightweight vpn to proxy adapter available, with a docker image size of 20 MB
- Split tunneling: set a whitelist of hosts, the vpn connection should be used for only, the rest is routed normally with your real ip
