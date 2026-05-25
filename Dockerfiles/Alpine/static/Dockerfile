# syntax=docker/dockerfile:1

# Static hosting (nginx) on Alpine. Serves /var/www/html on port 80 as the
# unprivileged docker user, same approach as the Ubuntu static image. Alpine
# includes server blocks from /etc/nginx/http.d.
ARG BASE_IMAGE=didstopia/base:alpine-3.22
FROM ${BASE_IMAGE}

USER root

ENV CHOWN_DIRS="/app,/var/www/html,/var/lib/nginx,/var/log/nginx"

RUN set -eux; \
    apk --no-cache add libcap nginx; \
    setcap 'cap_net_bind_service=+ep' "$(readlink -f "$(command -v nginx)")"; \
    sed -i -e '/^[[:space:]]*user[[:space:]]/d' -e '/^[[:space:]]*pid[[:space:]]/d' /etc/nginx/nginx.conf; \
    sed -i '1i pid /tmp/nginx.pid;' /etc/nginx/nginx.conf; \
    mkdir -p /var/www/html /var/log/nginx; \
    rm -rf /var/www/html/* /etc/nginx/http.d/default.conf

COPY Configs/nginx/default.conf /etc/nginx/http.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
