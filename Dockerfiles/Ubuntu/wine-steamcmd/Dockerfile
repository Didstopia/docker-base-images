# syntax=docker/dockerfile:1

# Wine + Xvfb layered on the SteamCMD image, for game servers that ship only a
# Windows build and have to run under Wine (Conan Exiles, The Forest, V Rising,
# ...). It bundles the bits those downstreams kept duplicating: the WineHQ stable
# repo, a headless X server, winbind/winetricks, and the 32-bit GL/Vulkan/SDL
# libraries the Unreal/Unity servers need. Like SteamCMD it is amd64 only
# (enforced in docker-bake.hcl) since Wine runs the x86 Windows binaries.
ARG BASE_IMAGE=didstopia/base:steamcmd-ubuntu-24.04
FROM ${BASE_IMAGE}

USER root
ARG DEBIAN_FRONTEND=noninteractive

# Default Wine prefix lives under /app (already owned by the docker user and in
# CHOWN_DIRS). Downstreams initialise it on first run and may override these.
ENV WINEPREFIX=/app/wine \
    WINEARCH=win64 \
    WINEDLLOVERRIDES="mscoree,mshtml="

# WineHQ stable plus the headless/runtime libraries. The i386 architecture and
# SteamCMD's 32-bit libs already come from the base. The WineHQ apt source is
# selected from the running release codename (jammy/noble), so this one
# Dockerfile covers every Ubuntu version in the matrix.
# hadolint ignore=DL3015
RUN set -eux; \
    dpkg --add-architecture i386; \
    mkdir -p /etc/apt/keyrings; \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key; \
    . /etc/os-release; \
    wget -NP /etc/apt/sources.list.d/ \
        "https://dl.winehq.org/wine-builds/ubuntu/dists/${VERSION_CODENAME}/winehq-${VERSION_CODENAME}.sources"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        cabextract \
        libsdl2-2.0-0:i386 \
        libegl1 \
        libegl1:i386 \
        libgl1 \
        libgl1:i386 \
        libvulkan1 \
        libvulkan1:i386 \
        mesa-vulkan-drivers \
        mesa-vulkan-drivers:i386 \
        winbind \
        winetricks \
        xauth \
        xvfb; \
    apt-get install -y --install-recommends winehq-stable; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# Wine is intentionally not run at build time. It executes x86 Windows binaries,
# which only works on a native amd64 host; running it here would break builds
# under emulation on arm64 machines (and trips the Apple Silicon 16 KB page
# assertion). Downstreams initialise the Wine prefix on first container start.
