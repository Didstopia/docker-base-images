# Base image
FROM ubuntu:16.04

# Maintainer information
MAINTAINER Didstopia <support@didstopia.com>

# Disable TTY interaction
ARG DEBIAN_FRONTEND=noninteractive

# Run as root by default
USER root

# Install gosu
ENV GOSU_VERSION 1.10
RUN set -ex; \
	\
	fetchDeps=' \
		ca-certificates \
		wget \
	'; \
	apt-get update; \
	apt-get install -y --no-install-recommends $fetchDeps; \
	rm -rf /var/lib/apt/lists/*; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
    # verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
	chmod +x /usr/local/bin/gosu; \
    # verify that the binary works
	gosu nobody true; \
	\
	apt-get purge -y --auto-remove $fetchDeps

# Update system packages, install core dependencies
# and generate default locales
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
    apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Create a default user and group (docker)
RUN groupadd \
        --system \
        --gid 1000 \
        docker && \
    useradd \
        --create-home \
        --home /app \
        --uid 1000 \
        --gid 1000 \
        --groups docker,users,staff \
        --shell /bin/false \
        docker

# Set default volume
VOLUME ["/app"]

# Set default environment variables
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.utf8
ENV TERM xterm
ENV TZ Etc/UTC
ENV PGID 0
ENV PUID 0

# Include Readme and License with each image
COPY README.md LICENSE.md /

# Add base image initialization script
ADD Scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the main entry point to our initialization script
ENTRYPOINT ["/entrypoint.sh"]

# Set the default command to run
CMD ["/bin/bash"]
