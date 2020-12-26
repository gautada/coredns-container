FROM alpine:3.12.1 as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:3.12.1 as src-coredns

WORKDIR /

RUN apk add --no-cache \
    git \
    go \
    tzdata

RUN cp /usr/share/zoneinfo/America/New_York /etc/localtime & \
    echo "America/New_York" > /etc/timezone & \
    date

# Pull the coredns source code from github. 
RUN git clone https://github.com/coredns/coredns.git coredns 

# @to-do: Pull the blacklist plugin source code from github.
# @to-do: REPLACE For now copy from the build context 
# COPY src/ /coredns/plugin/blacklist
# Add the blacklist plugin to the build manifest
# RUN printf "\nblacklist:blacklist\n" >> /coredns/plugin.cfg

WORKDIR /coredns                                                                                                                                                       
RUN go generate 
RUN go build                                                                                                          
RUN /coredns/coredns -plugins
WORKDIR /coredns                                                                                           
# COPY cache-builder.py /home/coredns/cache-builder.py

FROM alpine:3.12.1

EXPOSE 53/tcp 53/udp
EXPOSE 9153/tcp

RUN apk add --no-cache bind-tools
WORKDIR /

COPY --from=config-alpine /etc/localtime /etc/localtime
COPY --from=config-alpine /etc/timezone  /etc/timezone

COPY --from=src-coredns /coredns/coredns /usr/bin/coredns

# COPY hosts /etc/coredns/hosts
# COPY whitelist /etc/coredns/whitelist
# COPY blacklist /etc/coredns/blacklist
# COPY Corefile /etc/coredns/Corefile

# @to-do: Change this to entry point to accept arguments from k8s manifest
CMD ["/usr/bin/coredns", "-conf", "/etc/coredns/Corefile"]
