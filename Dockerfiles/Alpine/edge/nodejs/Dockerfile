# Base image
FROM didstopia/base:alpine-edge

# Maintainer information
LABEL maintainer="Didstopia <support@didstopia.com>"

# Install dependencies and verify that Node.js is working
RUN apk --no-cache add \
    curl \
    nodejs \
    nodejs-npm \
    jq \
    make \
    gcc \
    g++ \
    libstdc++ \
    libc6-compat \
    linux-headers \
    binutils-gold \
    python3 && \
    node -v && npm -v

# Update npm to the latest version
RUN npm install npm@latest -g

# Add Node.js initialization script
ADD Scripts/nodejs_init.sh /nodejs_init.sh
RUN chmod +x /nodejs_init.sh

# Run the Node.js initialization script as the default command
CMD ["/bin/bash", "/nodejs_init.sh"]
