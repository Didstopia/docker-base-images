FROM didstopia/base:ubuntu-14.04

MAINTAINER Didstopia <support@didstopia.com>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    lib32gcc1 \
    libstdc++6 && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /steamcmd && \
    curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz \
    | tar -v -C /steamcmd -zx && \
    chmod +x /steamcmd/steamcmd.sh && \
    /steamcmd/steamcmd.sh +login anonymous +quit
