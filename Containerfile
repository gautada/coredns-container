# Docker/Podman/OCI container build specfication file.
#
# References:
# - [Gist](https://gist.github.com/gautada/bd71914073b8e3a89ad13f0320b33010)
# - [Buildah Containerfile](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/building_running_and_managing_containers/assembly_building-container-images-with-buildah_building-running-and-managing-containers#proc_building-an-image-from-a-containerfile-with-buildah_assembly_building-container-images-with-buildah)
# - [Dockerfile](https://docs.docker.com/engine/reference/builder/)

ARG ALPINE_VERSION=3.15.4
# ╭―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╮
# │                                                                         │
# │ STAGE: src-coredns -- Build from soure                                  │
# │                                                                         │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/alpine:$ALPINE_VERSION as src-coredns

# ╭――――――――――――――――――――╮
# │ VERSION(S)         │
# ╰――――――――――――――――――――╯
ARG COREDNS_VERSION=1.9.3
ARG COREDNS_BRANCH=v$COREDNS_VERSION

# ╭――――――――――――――――――――╮
# │ PACKAGES           │
# ╰――――――――――――――――――――╯
RUN apk add --no-cache git go

# ╭――――――――――――――――――――╮
# │ SOURCE             │
# ╰――――――――――――――――――――╯
# Pull the coredns source code from github. 
RUN git config --global advice.detachedHead false
RUN git clone --branch $COREDNS_BRANCH --depth 1 https://github.com/coredns/coredns.git

# ╭――――――――――――――――――――╮
# │ BUILD              │
# ╰――――――――――――――――――――╯
WORKDIR /coredns
RUN go generate 
RUN go build


# ╭―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╮
# │                                                                         │
# │ STAG: coredns-container                                              │
# │                                                                         │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/alpine:$ALPINE_VERSION

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/coredns-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="This container is a coredns container."

# ╭――――――――――――――――――――╮
# │ STANDARD CONFIG    │
# ╰――――――――――――――――――――╯

# USER:
ARG USER=coredns

ARG UID=1001
ARG GID=1001
RUN /usr/sbin/addgroup -g $GID $USER \
 && /usr/sbin/adduser -D -G $USER -s /bin/ash -u $UID $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd

# PRIVILEGE:
COPY wheel  /etc/container/wheel

# BACKUP:
COPY backup /etc/container/backup

# ENTRYPOINT:
RUN rm -v /etc/container/entrypoint
COPY entrypoint /etc/container/entrypoint

# FOLDERS
RUN /bin/chown -R $USER:$USER /mnt/volumes/container \
 && /bin/chown -R $USER:$USER /mnt/volumes/backup \
 && /bin/chown -R $USER:$USER /var/backup \
 && /bin/chown -R $USER:$USER /tmp/backup

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
COPY --from=src-coredns /coredns/coredns /usr/bin/coredns
RUN apk add --no-cache py3-requests py3-yaml

RUN /bin/ln -fsv /mnt/volumes/container/Corefile /mnt/volumes/configmaps/Corefile \
 && /bin/ln -fsv /mnt/volumes/configmaps/Corefile /etc/container/Corefile

RUN /bin/ln -fsv /mnt/volumes/container/zone.local /mnt/volumes/configmaps/zone.local \
 && /bin/ln -fsv /mnt/volumes/configmaps/zone.local /etc/container/zone.local

RUN /bin/ln -fsv /mnt/volumes/container/zone.tld /mnt/volumes/configmaps/zone.tld \
 && /bin/ln -fsv /mnt/volumes/configmaps/zone.tld /etc/container/zone.tld
 
COPY blacklist /etc/container/blacklist
RUN chown $USER:$USER /etc/container/blacklist

RUN /bin/ln -fsv /mnt/volumes/container/blacklist.yml /mnt/volumes/configmaps/blacklist.yml \
 && /bin/ln -fsv /mnt/volumes/configmaps/blacklist.yml /etc/container/blacklist.yml

COPY update-blacklist /usr/bin/update-blacklist
RUN ln -fsv /usr/bin/update-blacklist /etc/periodic/daily/update-blacklist

RUN ln -s /mnt/volumes/container/backup.cer /etc/container/backup.cer
RUN rm /usr/bin/container-backup
RUN ln -s /mnt/volumes/container/container-backup /usr/bin/container-backup

RUN apk add --no-cache py3-pip py3-requests py3-yaml
# RUN pip install fastapi
# RUN pip install "uvicorn[standard]"

RUN /bin/ln -fsv /mnt/volumes/container/block.list /etc/container/block.list \
 && /bin/ln -fsv /mnt/volumes/container/white.list /etc/container/white.list \
 && /bin/ln -fsv /mnt/volumes/container/black.list /etc/container/black.list \
 && /bin/ln -fsv /mnt/volumes/container/hosts.yml /mnt/volumes/configmaps/hosts.yml \
 && /bin/ln -fsv /mnt/volumes/configmaps/hosts.yml /etc/container/hosts.yml

## BLACK HOLE
COPY blackhole.py /etc/container/blackhole.py
RUN /bin/ln -fsv /etc/container/blackhole.py /usr/bin/blackhole

# ╭――――――――――――――――――――╮
# │ CONTAINER          │
# ╰――――――――――――――――――――╯
# USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
EXPOSE 53/tcp 53/udp
EXPOSE 8080/tcp
EXPOSE 8081/tcp
EXPOSE 8181/tcp
EXPOSE 9153/tcp


