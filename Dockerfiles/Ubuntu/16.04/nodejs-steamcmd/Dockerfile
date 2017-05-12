FROM didstopia/base:steamcmd-ubuntu-16.04

MAINTAINER Didstopia <support@didstopia.com>

ARG DEBIAN_FRONTEND=noninteractive

RUN curl -sL https://deb.nodesource.com/setup_6.x \
    | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    nodejs \
    build-essential && \
    rm -rf /var/lib/apt/lists/*

ENV NODE_ENV production
