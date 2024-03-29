# Base image
FROM alpine:3.14

# Maintainer information
LABEL maintainer="Didstopia <support@didstopia.com>"

# Run as root by default
USER root

# Install and setup gosu
ENV GOSU_VERSION 1.14
RUN set -eux; \
	\
	apk add --no-cache --virtual .gosu-deps \
		ca-certificates \
		dpkg \
		gnupg \
	; \
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
	apk del --no-network .gosu-deps; \
	\
	chmod +x /usr/local/bin/gosu; \
	# verify that the binary works
	gosu --version; \
	gosu nobody true

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
# (also sets permissions for the /app volume)
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
ENV PGID 1000
ENV PUID 1000
ENV CHOWN_DIRS "/app"
ENV ENABLE_PASSWORDLESS_SUDO "false"

# Include Readme and License with each image
COPY README.md LICENSE.md /

# Add base image initialization script
ADD Scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the main entry point to our initialization script
ENTRYPOINT ["/entrypoint.sh"]

# Set the default command to run
CMD ["/bin/bash"]
