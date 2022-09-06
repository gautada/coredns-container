# CoreDNS

This container instantiates [CoreDNS](https://coredns.io) providing a DNS service with multiple aspects enabled through plugins. This container builds [CoreDNS from source](https://github.com/coredns/coredns) and provides the basic configuration stubs that are useful in the cluster and as a complete home DNS service.

**Plugins**

- **[kubernetes](https://coredns.io/plugins/kubernetes/)** - cluster dynamic name resolution
- **[file](https://coredns.io/plugins/file/)** - system name resolution using a zone file insidedescribing a private LAN
- **[hosts](https://coredns.io/plugins/hosts/)** - DNS based name resolution of a blacklist of domains..
- **[forward](https://coredns.io/plugins/forward/)** - local dns access for internet name resolution 


## Configuration

### Corefile

The primary configuration for coredns. This is where the all the plugins get initally loaded and configured. CoreDNS offers multiple plugins and good documentation to refer provided are the plugin configurations that provide the feature aspects described above.

```
.:53 {
...
        kubernetes cluster.local in-addr.arpa ip6.arpa {
            pods insecure
            fallthrough in-addr.arpa ip6.arpa
        }
        file /etc/coredns/zone.example.local example.local
        hosts /etc/coredns/hosts {
          no_reverse
          fallthrough
        }
        forward . tls://1.1.1.1 tls://1.0.0.1 {
          tls_servername tls.cloudflare-dns.com
        }
...
```

### kubernetes

This service is intended to run inside of a microk8s kubernetes cluster. As such the 
environment variables must be set to get the plugin working properly. 

plugin/kubernetes: unable to load in-cluster configuration, KUBERNETES_SERVICE
_HOST and KUBERNETES_SERVICE_PORT must be defined

KUBERNETES_SERVICE_HOST and KUBERNETES_SERVICE_PORT

docker run --env KUBERNETES_SERVICE_HOST=192.168.4.200 \
           --env KUBERNETES_SERVICE_PORT=16443 -it --rm \
           --name coredns coredns:build

https://help.dyn.com/how-to-format-a-zone-file/
 
### file

### hosts

Blacklist

https://firebog.net
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts

### forward

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

