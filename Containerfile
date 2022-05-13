ARG ALPINE_VERSION=3.15.4
FROM docker.io/gautada/alpine:$ALPINE_VERSION as src-coredns

ARG COREDNS_VERSION=1.8.4

ARG COREDNS_BRANCH=v$COREDNS_VERSION

USER root
WORKDIR /

RUN apk add --no-cache git go

# Pull the coredns source code from github. 
RUN git config --global advice.detachedHead false
RUN git clone --branch $COREDNS_BRANCH --depth 1 https://github.com/coredns/coredns.git

WORKDIR /coredns                                                                                                                                                       
RUN go generate 
RUN go build


#
# ------------------------------------------------------------- CONTAINER
FROM docker.io/gautada/alpine:$ALPINE_VERSION

LABEL source="https://github.com/gautada/coredns-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="This container is a coredns container."

USER root
WORKDIR /

EXPOSE 53/tcp 53/udp
EXPOSE 8080/tcp
EXPOSE 8181/tcp
EXPOSE 9153/tcp

COPY --from=src-coredns /coredns/coredns /usr/bin/coredns

RUN apk add --no-cache bind-tools

COPY config/Corefile /etc/coredns/Corefile
COPY config/zone.example.local /etc/coredns/zone.example.local
COPY config/hosts /etc/coredns/hosts 

ARG USER=coredns
VOLUME /opt/%USER
RUN /bin/mkdir -p /opt/$USER \
 && /usr/sbin/addgroup $USER \
 && /usr/sbin/adduser -D -s /bin/ash -G $USER $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd \
 && /bin/chown $USER:$USER -R /opt/$USER
 
USER $USER
WORKDIR /home/$USER
