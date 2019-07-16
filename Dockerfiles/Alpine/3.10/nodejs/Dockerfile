# Base image
FROM didstopia/base:alpine-3.10

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
    python && \
    node -v && npm -v

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
