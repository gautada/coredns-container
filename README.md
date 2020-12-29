# Container - CoreDNS

This is container for CoreDNS intended for use with the mk8s kubernetes cluster running on
RaspberryPIs.  This container builds from source and provides the basic configuration stubs
that are useful in the cluster and as a complete home DNS service.

## Upstream

* CoreDNS **v1.8.0**
 * [Project](https://coredns.io)
 * [github](https://github.com/coredns/coredns)
 
## Testing

Using digg to [test the dns server](https://www.a2hosting.com/kb/getting-started-guide/internet-and-networking/troubleshooting-dns-with-dig-and-nslookup):

```
<container exec> dig @172.0.0.1 test1.example.local
```
Expected response

```
<<GET EXAMPLE OUTPUT>>
```

## References

https://www.tldp.org/HOWTO/DNS-HOWTO-5.html

https://askubuntu.com/questions/907246/how-to-disable-systemd-resolved-in-ubuntu
[Deploying a DNS Server Using Docker(http://www.damagehead.com/blog/2015/04/28/deploying-a-dns-server-using-docker/)]
[Beginner's Guide to BIND(https://linuxtechlab.com/configuring-dns-server-using-bind/)]
[named Manual Page(https://linux.die.net/man/8/named)]
[example entrypoint.sh(https://github.com/cytopia/docker-bind/blob/master/data/docker-entrypoint.sh)]

