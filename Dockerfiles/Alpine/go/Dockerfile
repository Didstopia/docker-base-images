# syntax=docker/dockerfile:1

# Go on Alpine. Installs the official Go toolchain (statically linked, runs on
# musl) per architecture. Leave GO_VERSION empty to track the latest stable
# release, or pin it (for example 1.24.3) for reproducible builds.
ARG BASE_IMAGE=didstopia/base:alpine-3.22
FROM ${BASE_IMAGE}

USER root
ARG GO_VERSION=

ENV CHOWN_DIRS="/app,/go"
ENV GOPATH=/go
ENV GO111MODULE=on
ENV PATH=/usr/local/go/bin:/go/bin:$PATH

RUN set -eux; \
    apk --no-cache add ca-certificates tar wget; \
    case "$(uname -m)" in \
        x86_64) goArch=amd64 ;; \
        aarch64) goArch=arm64 ;; \
        *) echo "Unsupported architecture: $(uname -m)"; exit 1 ;; \
    esac; \
    version="${GO_VERSION}"; \
    if [ -z "$version" ]; then \
        version="$(wget -qO- https://go.dev/VERSION?m=text | head -n1)"; \
    else \
        version="go${version}"; \
    fi; \
    wget -O /tmp/go.tgz "https://go.dev/dl/${version}.linux-${goArch}.tar.gz"; \
    tar -C /usr/local -xzf /tmp/go.tgz; \
    rm /tmp/go.tgz; \
    mkdir -p "$GOPATH/src" "$GOPATH/bin"; \
    chmod -R 777 "$GOPATH"; \
    go version

WORKDIR $GOPATH

CMD ["/usr/local/go/bin/go", "version"]
