FROM didstopia/base:alpine-3.5

MAINTAINER Didstopia <support@didstopia.com>

RUN apk --no-cache add \
    bash \
    nodejs \
    jq \
    make \
    gcc \
    g++ \
    python

COPY Scripts/nodejs_init.sh /init.sh

RUN chmod +x /init.sh && \
    mkdir -p /app

VOLUME /app

EXPOSE 3000

ENTRYPOINT bash /init.sh
