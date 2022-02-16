## How to build
# docker build 
#    docker run -it -p 5053:53 --name test1 test:1
FROM debian:11
LABEL maintainer="net-mgr"
EXPOSE 53/udp
RUN apt-get update && apt-get upgrade && apt-get install -y dnsmasq
COPY dnsmasq.conf /etc/
COPY start.sh /start.sh
RUN chmod 555 /start.sh
CMD ["/start.sh"]
