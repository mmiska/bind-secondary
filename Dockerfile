FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive
ENV PRIMARY_SERVER=${PRIMARY_SERVER}
ENV SECONDARY_DOMAINS=${SECONDARY_DOMAINS}
ENV FORWARDER=${FORWARDER}
ENV RECURSION=${RECURSION}
ENV QUERY=${QUERY}

EXPOSE 53/udp
EXPOSE 53/tcp

WORKDIR /tmp


RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y dnsutils bind9
RUN find /var/lib/apt/lists -maxdepth 1 -type f -exec rm -iv {} \;
COPY named.conf.options /etc/bind/named.conf.options
RUN mkdir /run/named && chown bind.bind /run/named && chmod g+w /run/named
RUN mkdir /etc/bind/zones && chgrp bind /etc/bind/zones && chmod g+wx /etc/bind/zones

COPY createSecondaryConfig.sh /tmp/createSecondaryConfig.sh

ENTRYPOINT /tmp/createSecondaryConfig.sh
