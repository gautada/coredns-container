# coredns-blacklist
An IP blacklist plugin for coredns that is akin to PiHole.


## Docker

### Run Options

```
--publish 0.0.0.0:53:53/tcp --publish 0.0.0.0:53:53/udp --publish 0.0.0.0:9153:9153/tcp
```

## Flush Client DNS Settings

**macOS**
'''
sudo killall -HUP mDNSResponder
'''

**Note:** *No need to flush DNS on Ubuntu because there is no DNS caching on the system*

## DNS Server

Hosted on ```aegaeon.gautier.local``` the DNS is currently part of macOS Server

**Forwarding Servers:** A list of servers that could be used for DNS on machines if I want to override the settings
- 84.200.69.80 - resolver1.dns.watch
- 84.200.70.40 - resolver2.dns.watch
- 8.8.8.8 - Google
- 8.8.4.4 - Google

**Router DNS Configuration: ** The settings in the **eero** router
- 10.0.0.20 — aegean as the default DNS server
- 84.200.70.40 - resolver2.dns.watch

### Alternate DNS Servers

From the list of "[The Top 5 Best DNS Servers for improving Online Privacy & Security(https://securitytrails.com/blog/dns-servers-privacy-security)]" based o$

**Cloud Flare**
1.1.1.1, 1.0.0.1, 2606:4700:4700::1111, 2606:4700:4700::1001
**Open DNS**
208.67.222.123, 208.67.220.123
**DNS Watch**
84.200.69.80, 84.200.70.40
 **Quad9 DNS**
 9.9.9.9, 149.112.112.112
 **Google DNS**
 8.8.8.8, 8.8.4.4

## Notes

### macOS Server DNS would not start after update

https://discussions.apple.com/message/27811890#27811890

Command to correct error:
```
launchctl load -w /Applications/Server.app/Contents/ServerRoot/System/Library/LaunchDaemons/org.isc.named.plist
```

### Add a Wildcard domain to macOS Server DNS

https://apple.stackexchange.com/questions/145905/how-to-add-a-wildcard-host-entry-to-mac-os-x-servers-dns

## Development

To use bind on a local docker system for development. Launch the following docker image.

```
docker run --detach=true --hostname=$IMAGE.gautier.local --ip=172.22.0.5 --name=$IMAGE.gautier.docker --network=gautier.docker --publish=53:53/tcp --publish=$
```

## Testing

To test that the docker network is working as expect run:

```
docker run --dns=172.22.0.6 --dns=84.200.69.80 --network=gautier.docker --rm alpine:latest ping -c 5 saturn.gautier.local
docker run --dns=172.15.0.2 --dns=84.200.69.80 --network=gautier.docker --rm alpine:latest ping -c 5 bind.gautier.docker
docker run --dns=172.15.0.2 --dns=84.200.69.80 --network=gautier.docker --rm alpine:latest ping -c 5 google.com
```
Using digg to [test the dns server](https://www.a2hosting.com/kb/getting-started-guide/internet-and-networking/troubleshooting-dns-with-dig-and-nslookup):

```
dig @172.16.0.30 aegaeon.gautier.local
```
Expected response

```
; <<>> DiG 9.10.6 <<>> @172.16.0.30 aegaeon.gautier.local
; (1 server found)
;; global options: +cmd
;; Got answer:
;; WARNING: .local is reserved for Multicast DNS
;; You are currently testing what happens when an mDNS query is leaked to DNS
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 24004
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;aegaeon.gautier.local.        IN    A

;; ANSWER SECTION:
aegaeon.gautier.local.    259200    IN    A    172.16.0.5

;; Query time: 4 msec
;; SERVER: 172.16.0.30#53(172.16.0.30)
;; WHEN: Sat Oct 13 20:16:50 EDT 2018
;; MSG SIZE  rcvd: 66
```

## References

https://www.tldp.org/HOWTO/DNS-HOWTO-5.html

https://askubuntu.com/questions/907246/how-to-disable-systemd-resolved-in-ubuntu


lrwxrwxrwx 1 root root 39 Apr 26 19:07 /etc/resolv.conf -> ../run/systemd/resolve/stub-resolv.conf
mada@epimetheus:~$

[Deploying a DNS Server Using Docker(http://www.damagehead.com/blog/2015/04/28/deploying-a-dns-server-using-docker/)]
[Beginner's Guide to BIND(https://linuxtechlab.com/configuring-dns-server-using-bind/)]
[named Manual Page(https://linux.die.net/man/8/named)]
[example entrypoint.sh(https://github.com/cytopia/docker-bind/blob/master/data/docker-entrypoint.sh)]

