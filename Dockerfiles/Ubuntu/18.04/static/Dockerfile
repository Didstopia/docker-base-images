# Base image
FROM didstopia/base:ubuntu-18.04

# Maintainer information
LABEL maintainer="Didstopia <support@didstopia.com>"

# Disable TTY interaction
ARG DEBIAN_FRONTEND=noninteractive

# Install nginx
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx && \
    apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

## TODO: We should probably customize nginx more,
##       so it fits better inside a container and for static hosting

## TODO: These are from the Alpine images, so might not be accurate!

# Create the necessary folder structure
RUN mkdir -p /run/nginx

# Remove the default website
RUN rm -fr /var/lib/nginx/html/*

# Replace the default website configuration
COPY Configs/nginx/default.conf /etc/nginx/conf.d/default.conf

# Expose the HTTP port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
