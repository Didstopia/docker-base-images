# Base image
FROM didstopia/base:alpine-3.10

# Maintainer information
LABEL maintainer="Didstopia <support@didstopia.com>"

# Install nginx
RUN apk --no-cache add \
		nginx

## TODO: We should probably customize nginx more,
##       so it fits better inside a container and for static hosting

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
