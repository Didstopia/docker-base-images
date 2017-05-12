FROM ubuntu:16.04

MAINTAINER Didstopia <support@didstopia.com>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install apt-utils -y --no-install-recommends && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    software-properties-common \
    python-software-properties \
    locales \
    wget \
    curl \
    bsdtar && \
    apt-get upgrade -y && \
    apt-get dist-upgrade -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

COPY README.md LICENSE.md /
