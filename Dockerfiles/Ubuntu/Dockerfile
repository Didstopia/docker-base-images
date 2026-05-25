# syntax=docker/dockerfile:1

# Ubuntu base image. UBUNTU_VERSION picks the LTS line, so 22.04 and 24.04
# share this one Dockerfile.
ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

# Build as root
USER root
ARG DEBIAN_FRONTEND=noninteractive

# gosu lets the entrypoint drop from root to the docker user at runtime.
# Binary is fetched per architecture and its signature is verified.
ARG GOSU_VERSION=1.19
RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates gnupg wget; \
    rm -rf /var/lib/apt/lists/*; \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${dpkgArch}"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${dpkgArch}.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    gpgconf --kill all || :; \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    chmod +x /usr/local/bin/gosu; \
    gosu --version; \
    gosu nobody true

# Core packages, locale and timezone data, fully upgraded
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        gnupg \
        libarchive-tools \
        locales \
        sudo \
        tzdata \
        wget; \
    apt-get upgrade -y; \
    apt-get dist-upgrade -y; \
    apt-get autoremove -y; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*; \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Ubuntu 24.04 ships a default uid 1000 "ubuntu" user. Remove it so our
# docker user can own 1000, matching every earlier image in this repo.
RUN set -eux; \
    if id ubuntu >/dev/null 2>&1; then userdel -r ubuntu 2>/dev/null || true; fi; \
    groupadd --system --gid 1000 docker; \
    useradd --create-home --home /app --uid 1000 --gid 1000 \
        --groups users,staff --shell /bin/false docker; \
    mkdir -p /app; \
    chown -R docker:docker /app

# Defaults. PUID/PGID and CHOWN_DIRS are consumed by the entrypoint.
ENV LANGUAGE=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TERM=xterm \
    TZ=Etc/UTC \
    PGID=1000 \
    PUID=1000 \
    CHOWN_DIRS=/app \
    ENABLE_PASSWORDLESS_SUDO=false

# Ship the readme and license inside the image, same as before
COPY README.md LICENSE.md /

# Entrypoint handles uid/gid remapping then drops to the docker user
COPY Scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
