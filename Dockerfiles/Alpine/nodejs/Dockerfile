# syntax=docker/dockerfile:1

# Node.js on Alpine. Alpine ships a current LTS Node in its community repo, so
# the version tracks the Alpine release rather than a NODE_MAJOR arg. Build
# tooling for native addons (node-gyp) is included.
ARG BASE_IMAGE=didstopia/base:alpine-3.22
FROM ${BASE_IMAGE}

USER root

RUN set -eux; \
    apk --no-cache add \
        g++ \
        gcc \
        jq \
        libc6-compat \
        linux-headers \
        make \
        nodejs \
        npm \
        python3; \
    node -v; \
    npm -v

COPY Scripts/nodejs_init.sh /nodejs_init.sh
RUN chmod +x /nodejs_init.sh

CMD ["/bin/bash", "/nodejs_init.sh"]
