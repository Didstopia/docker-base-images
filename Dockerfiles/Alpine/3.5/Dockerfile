# Base image
FROM alpine:3.5

# Maintainer information
MAINTAINER Didstopia <support@didstopia.com>

# Run as root by default
USER root

# Update system packages and install core dependencies
RUN apk --no-cache upgrade && \
    apk --no-cache add \
    bash \
    busybox-suid \
    shadow

# Install gosu
ENV GOSU_VERSION 1.10
RUN set -ex; \
	\
	apk add --no-cache --virtual .gosu-deps \
		dpkg \
		gnupg \
		openssl \
	; \
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
	apk del .gosu-deps

# Create a default user and group (docker)
RUN addgroup \
        -S \
        -g 1000 \
        docker && \
    adduser \
        -D \
        -h /app \
        -u 1000 \
        -G docker \
        -s /bin/false \
        docker && \
    usermod \
        -a \
        -G docker,users \
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
