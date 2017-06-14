FROM didstopia/base:alpine-3.5

MAINTAINER Didstopia <support@didstopia.com>

ENV NODEJS_SOURCE_URL="https://nodejs.org/dist/v8.1.1/node-v8.1.1.tar.gz"

RUN apk --no-cache add \
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

RUN mkdir -p /tmp/nodejs && \
    curl -sSL ${NODEJS_SOURCE_URL} | \
    tar xvz -C /tmp/nodejs && \
    cd /tmp/nodejs/*/. && \
    ./configure && \
    make && \
    make install

RUN node -v && npm -v 

COPY Scripts/nodejs_init.sh /init.sh

RUN chmod +x /init.sh && \
    mkdir -p /app

VOLUME /app

EXPOSE 3000

ENTRYPOINT bash /init.sh
