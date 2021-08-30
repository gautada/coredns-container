ARG ALPINE_TAG=3.14.1
ARG BRANCH=v0.0.0

FROM alpine:$ALPINE_TAG as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:$ALPINE_TAG as src-coredns

RUN apk add --no-cache git go

# Pull the coredns source code from github. 
RUN git config --global advice.detachedHead false
RUN git clone --branch $BRANCH --depth 1 https://github.com/coredns/coredns.git coredns

WORKDIR /coredns                                                                                                                                                       
RUN go generate 
RUN go build

FROM alpine:$ALPINE_TAG

COPY --from=config-alpine /etc/localtime /etc/localtime
COPY --from=config-alpine /etc/timezone  /etc/timezone

EXPOSE 53/tcp 53/udp
EXPOSE 8080/tcp
EXPOSE 8181/tcp
EXPOSE 9153/tcp

RUN apk add --no-cache bind-tools

COPY --from=src-coredns /coredns/coredns /usr/bin/coredns

COPY config/Corefile /etc/coredns/Corefile
COPY config/zone.example.local /etc/coredns/zone.example.local
COPY config/hosts /etc/coredns/hosts 

ENTRYPOINT ["/usr/bin/coredns"]
CMD ["-conf", "/etc/coredns/Corefile"]