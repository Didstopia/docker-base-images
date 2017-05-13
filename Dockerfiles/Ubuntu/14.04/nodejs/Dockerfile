FROM didstopia/base:ubuntu-14.04

MAINTAINER Didstopia <support@didstopia.com>

ARG DEBIAN_FRONTEND=noninteractive

RUN curl -sL https://deb.nodesource.com/setup_6.x \
    | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    nodejs \
    jq \
    build-essential && \
    rm -rf /var/lib/apt/lists/*

COPY Scripts/nodejs_init.sh /init.sh

RUN chmod +x /init.sh && \
    mkdir -p /app

VOLUME /app

EXPOSE 3000

ENTRYPOINT bash /init.sh
