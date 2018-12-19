# Base image
FROM alpine:3.5

# Maintainer information
LABEL maintainer="Didstopia <support@didstopia.com>"

# Run as root by default
USER root

# Install gosu
ENV GOSU_VERSION 1.11
RUN set -ex; \
	\
	apk update \
	; \
	\
	apk add --no-cache --virtual .gosu-deps \
		ca-certificates \
		dpkg \
		gnupg \
		openssl \
	; \
	\
	# update certificates
	update-ca-certificates 2>/dev/null || true; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget --no-check-certificate -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget --no-check-certificate -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
	# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	(gpg --keyserver hkp://p80.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 || \
		gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 || \
		gpg --keyserver hkp://pgp.mit.edu --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4); \
	#gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
	chmod +x /usr/local/bin/gosu; \
	# verify that the binary works
	gosu nobody true; \
	\
	apk del .gosu-deps

# Update system packages and install core dependencies
RUN apk update && \
		apk --no-cache upgrade && \
    apk --no-cache add \
			bash \
			busybox-suid \
			shadow \
			ca-certificates && \
			update-ca-certificates 2>/dev/null || true

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
#VOLUME ["/app"]

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
