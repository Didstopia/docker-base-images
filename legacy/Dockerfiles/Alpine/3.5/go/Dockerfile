# Base image
FROM didstopia/base:alpine-3.5

# Maintainer information
LABEL maintainer="Didstopia <support@didstopia.com>"

# Expose an overridable version of Go
ARG GO_VERSION=1.14

# Define directories to take ownership of
ENV CHOWN_DIRS "/app,/go"

# Install temporary build deps for Go
RUN apk update && \
    #apk add --no-cache --virtual .go-build-deps \
    apk add --no-cache \
    bash \
    gcc \
    musl-dev \
    openssl \
    git \
    make \
    gcc \
    wget \
    go

# Download and compile Go
RUN wget --no-check-certificate -O /tmp/go.tgz https://dl.google.com/go/go${GO_VERSION}.src.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tgz && \
    rm /tmp/go.tgz && \
    cd /usr/local/go/src && \
    export GOROOT_BOOTSTRAP="$(go env GOROOT)" GOOS="$(go env GOOS)" GOARCH="$(go env GOARCH)" GOHOSTOS="$(go env GOHOSTOS)" GOHOSTARCH="$(go env GOHOSTARCH)" export GO386='387' && \
    ./make.bash && \
    rm -rf /usr/local/go/pkg/bootstrap /usr/local/go/pkg/obj && \
    #apk del .go-build-deps && \
    export PATH="/usr/local/go/bin:$PATH" && \
    go version && which go

# Configure Go specific environment variables
ENV GO111MODULE=on
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

# Setup the necessary Go directory structure & permissions
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

# Set the default working directory
WORKDIR $GOPATH

# Run the Node.js initialization script as the default command
CMD ["/usr/local/go/bin/go", "run", "./..."]
