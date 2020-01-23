# Base image
FROM ubuntu:16.04

# Maintainer information
LABEL maintainer="Didstopia <support@didstopia.com>"

# Disable TTY interaction
ARG DEBIAN_FRONTEND=noninteractive

# Run as root by default
USER root

# Install and setup gosu
# More information at https://github.com/tianon/gosu/blob/master/INSTALL.md
ENV GOSU_VERSION 1.11
RUN set -eux; \
    # save list of currently installed packages for later so we can clean up
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends ca-certificates wget; \
	if ! command -v gpg; then \
		apt-get install -y --no-install-recommends gnupg2 dirmngr; \
	elif gpg --version | grep -q '^gpg (GnuPG) 1\.'; then \
    # "This package provides support for HKPS keyservers." (GnuPG 1.x only)
		apt-get install -y --no-install-recommends gnupg-curl; \
	fi; \
	rm -rf /var/lib/apt/lists/*; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
    # verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	command -v gpgconf && gpgconf --kill all || :; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
    # clean up fetch dependencies
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	\
	chmod +x /usr/local/bin/gosu; \
    # verify that the binary works
	gosu --version; \
	gosu nobody true

# Update system packages, install core dependencies and generate default locales
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
# (also sets permissions for the /app volume)
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
        docker && \
    mkdir -p /app && \
	chown -R docker:docker /app

# Expose the /app volume
#VOLUME [ "/app" ]

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
