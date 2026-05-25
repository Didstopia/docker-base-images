# syntax=docker/dockerfile:1

# Node.js on Ubuntu. BASE_IMAGE points at one of our Ubuntu base tags and
# NODE_MAJOR picks the Node line (22 or 24). bake wires BASE_IMAGE to the
# locally built base target so this builds without an intermediate push.
ARG BASE_IMAGE=didstopia/base:ubuntu-24.04
FROM ${BASE_IMAGE}

USER root
ARG DEBIAN_FRONTEND=noninteractive
ARG NODE_MAJOR=22

# Install Node.js from the NodeSource apt repo using the current keyring
# method, plus the toolchain node-gyp needs (build-essential, python3).
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

# Fail the build if the installed major does not match what was requested
RUN set -eux; \
    installed="$(node -v)"; \
    case "$installed" in \
        v${NODE_MAJOR}.*) echo "Node ${installed} ok" ;; \
        *) echo "Expected Node v${NODE_MAJOR}.x, got ${installed}"; exit 1 ;; \
    esac

# Optional helper that installs/builds/starts an /app project on container start
COPY Scripts/nodejs_init.sh /nodejs_init.sh
RUN chmod +x /nodejs_init.sh

CMD ["/bin/bash", "/nodejs_init.sh"]
