FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive
ENV BIND_FORWARDER=${BIND_FORWARDER:-8.8.8.8}
ENV PRIMARY_SERVER=${PRIMARY_SERVER}
ENV SECONDARY_DOMAINS=${SECONDARY_DOMAINS}
ENV FORWARDER=${FORWARDER}
ENV RECURSION=${RECURSION}
ENV QUERY=${QUERY}

WORKDIR /tmp


RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y dnsutils bind9
COPY named.conf.options /etc/bind/named.conf.options
RUN mkdir /run/named && chown bind.bind /run/named && chmod g+w /run/named
RUN mkdir /etc/bind/zones && chgrp bind /etc/bind/zones && chmod g+wx /etc/bind/zones

COPY createSecondaryConfig.sh /tmp/createSecondaryConfig.sh
ENTRYPOINT /tmp/createSecondaryConfig.sh