# syntax=docker/dockerfile:1

# SteamCMD on Ubuntu. SteamCMD is a 32-bit x86 binary with no arm64 build,
# so this image is amd64 only (enforced in docker-bake.hcl).
ARG BASE_IMAGE=didstopia/base:ubuntu-24.04
FROM ${BASE_IMAGE}

USER root
ARG DEBIAN_FRONTEND=noninteractive

ENV CHOWN_DIRS="/app,/steamcmd"

# i386 runtime libraries SteamCMD depends on, then the SteamCMD bootstrap
# itself into /steamcmd. lib32gcc-s1 replaced the old lib32gcc1.
RUN set -eux; \
    dpkg --add-architecture i386; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        lib32gcc-s1 \
        lib32stdc++6; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*; \
    mkdir -p /steamcmd; \
    curl -fsSL https://media.steampowered.com/installer/steamcmd_linux.tar.gz \
        | tar -xz -C /steamcmd; \
    chmod +x /steamcmd/steamcmd.sh; \
    ln -sf /steamcmd/steamcmd.sh /usr/local/bin/steamcmd; \
    test -f /steamcmd/steamcmd.sh

# SteamCMD self-updates and pulls its runtime on first run. We intentionally do
# not run it at build time: it is a 32-bit x86 binary, so executing it during a
# build only works on a native amd64 host, which would stop the image from
# building under emulation on arm64 machines and CI.
