# Base image
FROM didstopia/base:steamcmd-ubuntu-16.04

# Maintainer information
LABEL maintainer="Didstopia <support@didstopia.com>"

# Disable TTY interaction
ARG DEBIAN_FRONTEND=noninteractive

# Default Node.js version
ARG NODE_VERSION="10"

# Install dependencies and verify that Node.js is working
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    nodejs \
    jq \
    build-essential && \
    node -v && npm -v && \
    apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

# Update npm to the latest version
RUN npm install npm@latest -g

# Add Node.js initialization script
ADD Scripts/nodejs_init.sh /nodejs_init.sh
RUN chmod +x /nodejs_init.sh

# Run as the "docker" user by default
ENV PGID 1000
ENV PUID 1000

# Expose ports
EXPOSE 3000

# Run the Node.js initialization script as the default command
CMD ["/bin/bash", "/nodejs_init.sh"]
