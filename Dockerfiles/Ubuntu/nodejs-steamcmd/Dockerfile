# syntax=docker/dockerfile:1

# Node.js layered on top of the SteamCMD image. BASE_IMAGE points at one of
# our steamcmd-ubuntu tags. amd64 only, inherited from SteamCMD.
ARG BASE_IMAGE=didstopia/base:steamcmd-ubuntu-24.04
FROM ${BASE_IMAGE}

USER root
ARG DEBIAN_FRONTEND=noninteractive
ARG NODE_MAJOR=22

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
        > /etc/apt/sources.list.d/nodesource.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        jq \
        nodejs \
        python3 \
        python3-dev; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*; \
    node -v; \
    npm -v

RUN set -eux; \
    installed="$(node -v)"; \
    case "$installed" in \
        v${NODE_MAJOR}.*) echo "Node ${installed} ok" ;; \
        *) echo "Expected Node v${NODE_MAJOR}.x, got ${installed}"; exit 1 ;; \
    esac

COPY Scripts/nodejs_init.sh /nodejs_init.sh
RUN chmod +x /nodejs_init.sh

CMD ["/bin/bash", "/nodejs_init.sh"]
