# syntax=docker/dockerfile:1

# Alpine base image. ALPINE_VERSION picks the release so the stable lines and
# edge share this one Dockerfile.
ARG ALPINE_VERSION=3.22
FROM alpine:${ALPINE_VERSION}

USER root

# Core packages. su-exec is Alpine's tiny equivalent of gosu and is symlinked
# as gosu so the shared entrypoint works unchanged across Ubuntu and Alpine.
# shadow provides usermod/groupmod that the entrypoint calls at runtime.
RUN set -eux; \
    apk --no-cache upgrade; \
    apk --no-cache add \
        bash \
        busybox-suid \
        ca-certificates \
        curl \
        git \
        shadow \
        su-exec \
        tzdata; \
    update-ca-certificates 2>/dev/null || true; \
    ln -sf "$(command -v su-exec)" /usr/local/bin/gosu

# Create the docker user and group, owning /app
RUN set -eux; \
    addgroup -S -g 1000 docker; \
    adduser -D -h /app -u 1000 -G docker -s /bin/false docker; \
    addgroup docker users; \
    mkdir -p /app; \
    chown -R docker:docker /app

ENV LANGUAGE=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TERM=xterm \
    TZ=Etc/UTC \
    PGID=1000 \
    PUID=1000 \
    CHOWN_DIRS=/app \
    ENABLE_PASSWORDLESS_SUDO=false

COPY README.md LICENSE.md /

COPY Scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
