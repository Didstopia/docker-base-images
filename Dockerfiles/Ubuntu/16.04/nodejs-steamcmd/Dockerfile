# Base image
FROM didstopia/base:steamcmd-ubuntu-16.04

# Maintainer information
LABEL maintainer="Didstopia <support@didstopia.com>"

# Disable TTY interaction
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies and verify that Node.js is working
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
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

# Add Node.js initialization script
ADD Scripts/nodejs_init.sh /nodejs_init.sh
RUN chmod +x /nodejs_init.sh

# Run as the "docker" user by default
ENV PGID 1000
ENV PUID 1000

# Expose ports
EXPOSE 3000

# When this image is used as a base image for other images,
# we will automatically install Node.js dependencies (if necessary)
ONBUILD RUN if [ -f /app/package.json ]; then cd /app && npm install; fi

# Run the Node.js initialization script as the default command
CMD ["/bin/bash", "/nodejs_init.sh"]
