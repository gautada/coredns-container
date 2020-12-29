FROM alpine:3.12.1 as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:3.12.1 as src-coredns

COPY --from=config-alpine /etc/localtime /etc/localtime
COPY --from=config-alpine /etc/timezone  /etc/timezone

RUN apk add --no-cache git go


# Pull the coredns source code from github. 
RUN git clone --branch v1.8.0 --depth 1 https://github.com/coredns/coredns.git coredns

WORKDIR /coredns                                                                                                                                                       
RUN go generate 
RUN go build

FROM alpine:3.12.1

COPY --from=config-alpine /etc/localtime /etc/localtime
COPY --from=config-alpine /etc/timezone  /etc/timezone

EXPOSE 53/tcp 53/udp
EXPOSE 9153/tcp

RUN apk add --no-cache bind-tools

COPY --from=src-coredns /coredns/coredns /usr/bin/coredns
COPY Corefile /etc/coredns/Corefile

ENTRYPOINT ["/usr/bin/coredns"]
CMD ["-conf", "/etc/coredns/Corefile"]
