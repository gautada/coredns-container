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
# RUN chmod -x /etc/entrypoint.d/00-ep-bastion.sh /etc/entrypoint.d/01-ep-crond.sh /etc/entrypoint.d/99-ep-exec.sh
COPY --from=src-coredns /coredns/coredns /usr/bin/coredns
COPY 10-ep-container.sh /etc/entrypoint.d/10-ep-container.sh
RUN mkdir -p /etc/coredns \
 && ln -s /opt/coredns/Corefile /etc/coredns/Corefile \
 && ln -s /opt/coredns/zone.example.local /etc/coredns/zone.example.local \
 && ln -s /opt/coredns/hosts /etc/coredns/hosts


USER $USER
WORKDIR /home/$USER
EXPOSE 53/tcp 53/udp
EXPOSE 8080/tcp
EXPOSE 8181/tcp
EXPOSE 9153/tcp
