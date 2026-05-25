# syntax=docker/dockerfile:1

# Static hosting (nginx) on Ubuntu. Serves /var/www/html on port 80. nginx
# runs as the unprivileged docker user, so the binary is granted
# cap_net_bind_service to bind port 80 and the pid/temp paths are made writable.
ARG BASE_IMAGE=didstopia/base:ubuntu-24.04
FROM ${BASE_IMAGE}

USER root
ARG DEBIAN_FRONTEND=noninteractive

ENV CHOWN_DIRS="/app,/var/www/html,/var/lib/nginx,/var/log/nginx"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends libcap2-bin nginx; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*; \
    setcap 'cap_net_bind_service=+ep' "$(readlink -f "$(command -v nginx)")"; \
    sed -i -e '/^[[:space:]]*user[[:space:]]/d' -e '/^[[:space:]]*pid[[:space:]]/d' /etc/nginx/nginx.conf; \
    sed -i '1i pid /tmp/nginx.pid;' /etc/nginx/nginx.conf; \
    rm -f /etc/nginx/sites-enabled/default; \
    mkdir -p /var/www/html; \
    rm -rf /var/www/html/*

COPY Configs/nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
