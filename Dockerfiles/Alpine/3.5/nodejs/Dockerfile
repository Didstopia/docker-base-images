FROM didstopia/base:alpine-3.5

MAINTAINER Didstopia <support@didstopia.com>

RUN addgroup -g 1000 node \
    && adduser -u 1000 -G node -s /bin/sh -D node && \
    apk --no-cache add \
    bash \
    curl \
    nodejs \
    jq \
    make \
    gcc \
    g++ \
    libstdc++ \
    linux-headers \
    binutils-gold \
    python

RUN node -v && npm -v 

COPY Scripts/nodejs_init.sh /init.sh

RUN chmod +x /init.sh && \
    mkdir -p /app

VOLUME /app

USER node

EXPOSE 3000

ENTRYPOINT bash /init.sh
