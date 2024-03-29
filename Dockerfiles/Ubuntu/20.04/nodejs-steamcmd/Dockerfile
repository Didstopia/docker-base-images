# Base image
FROM didstopia/base:steamcmd-ubuntu-20.04

# Maintainer information
LABEL maintainer="Didstopia <support@didstopia.com>"

# Disable TTY interaction
ARG DEBIAN_FRONTEND=noninteractive

# Default Node.js version
ARG NODE_VERSION=14

# Install dependencies and verify that Node.js is working
RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    nodejs \
    python-dev \
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

# Validate the Node.js version
RUN bash -c 'if [[ $(node -v) != v$NODE_VERSION* ]]; then echo "Incorrect Node.js version detected: $(node -v) (expected v${NODE_VERSION}.*)"; exit 1; fi'

# Add Node.js initialization script
ADD Scripts/nodejs_init.sh /nodejs_init.sh
RUN chmod +x /nodejs_init.sh

# Run the Node.js initialization script as the default command
CMD ["/bin/bash", "/nodejs_init.sh"]
