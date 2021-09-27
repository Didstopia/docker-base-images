# Base image
FROM didstopia/base:ubuntu-20.04

# Maintainer information
LABEL maintainer="Didstopia <support@didstopia.com>"

# Disable TTY interaction
ARG DEBIAN_FRONTEND=noninteractive

# Define directories to take ownership of
ENV CHOWN_DIRS "/app,/steamcmd"

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

# Fix issues with libcurl and steamcmd
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev:i386 && \
    ls -la /usr/lib/*/libcurl.so* && \
    ln -sf /usr/lib/i386-linux-gnu/libcurl.so.4 /usr/lib/i386-linux-gnu/libcurl.so && \
    ln -sf /usr/lib/i386-linux-gnu/libcurl.so.4 /usr/lib/i386-linux-gnu/libcurl.so.3 && \
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
