## Build
# $ docker build -t dnsmasq .

FROM alpine:3.15
LABEL maintainer="net-mgr"

# Expose tcp and udp 53 port
EXPOSE 53 53/udp

# Install dnsmasq with package manager
RUN apk --no-cache add dnsmasq

# Run dnsmasq with -k (keep in foreground) option
CMD ["dnsmasq", "-k"]
