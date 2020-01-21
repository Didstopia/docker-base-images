# Base image
FROM didstopia/base:ubuntu-18.04

# Maintainer information
LABEL maintainer="Didstopia <support@didstopia.com>"

# Disable TTY interaction
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    lib32gcc1 \
    libstdc++6 && \
    apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

# Install steamcmd and verify that it is working
RUN mkdir -p /steamcmd && \
    curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz \
    | tar -v -C /steamcmd -zx && \
    chmod +x /steamcmd/steamcmd.sh && \
    /steamcmd/steamcmd.sh +login anonymous +quit
