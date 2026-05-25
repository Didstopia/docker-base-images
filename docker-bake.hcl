# docker-bake.hcl
#
# Single source of truth for the whole image graph. Replaces docker-make and
# the old .ci shell scripts. Variant images pull their base via the `contexts`
# wiring below, so the entire graph builds in dependency order in one `bake`
# call with no intermediate pushes.
#
# Common commands:
#   docker buildx bake                      # build everything (build cache only)
#   docker buildx bake ubuntu               # build the Ubuntu group
#   docker buildx bake nodejs-ubuntu        # build just the Node.js on Ubuntu targets
#   docker buildx bake --push               # build and push (CI sets the registries)
#   docker buildx bake ubuntu-24-04 --set "*.platform=linux/arm64" --load
#
# Versions can be overridden from the environment, for example:
#   NODE_VERSIONS='["24"]' docker buildx bake nodejs-ubuntu

variable "REGISTRY" {
  default = "didstopia/base"
}

# Second registry to also tag (e.g. ghcr.io/didstopia/base). Empty disables it,
# so local builds only produce didstopia/base tags. CI sets this.
variable "GHCR_REGISTRY" {
  default = ""
}

variable "GOSU_VERSION" {
  default = "1.19"
}

# Empty means the Go image tracks the latest stable release at build time.
variable "GO_VERSION" {
  default = ""
}

variable "UBUNTU_VERSIONS" {
  default = ["22.04", "24.04"]
}

variable "ALPINE_VERSIONS" {
  default = ["3.22", "3.23", "edge"]
}

variable "NODE_VERSIONS" {
  default = ["22", "24"]
}

# Default platforms for multi-arch targets. steamcmd targets override this to
# amd64 only since SteamCMD has no arm64 build.
variable "PLATFORMS" {
  default = ["linux/amd64", "linux/arm64"]
}

# OCI metadata, filled in by CI from git. Safe to leave empty locally.
variable "VCS_REF" {
  default = ""
}
variable "BUILD_DATE" {
  default = ""
}
variable "VERSION" {
  default = ""
}

# Tag a name on Docker Hub, and on GHCR too when GHCR_REGISTRY is set.
function "tags" {
  params = [name]
  result = GHCR_REGISTRY != "" ? ["${REGISTRY}:${name}", "${GHCR_REGISTRY}:${name}"] : ["${REGISTRY}:${name}"]
}

target "_common" {
  context = "."
  labels = {
    "org.opencontainers.image.source"   = "https://github.com/Didstopia/docker-base-images"
    "org.opencontainers.image.url"      = "https://github.com/Didstopia/docker-base-images"
    "org.opencontainers.image.vendor"   = "Didstopia"
    "org.opencontainers.image.authors"  = "Didstopia <support@didstopia.com>"
    "org.opencontainers.image.licenses" = "MIT"
    "org.opencontainers.image.revision" = "${VCS_REF}"
    "org.opencontainers.image.created"  = "${BUILD_DATE}"
    "org.opencontainers.image.version"  = "${VERSION}"
  }
}

# ----------------------------------------------------------------------------
# Ubuntu
# ----------------------------------------------------------------------------

target "ubuntu-base" {
  inherits   = ["_common"]
  matrix     = { ver = UBUNTU_VERSIONS }
  name       = "ubuntu-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Ubuntu/Dockerfile"
  args = {
    UBUNTU_VERSION = ver
    GOSU_VERSION   = GOSU_VERSION
  }
  tags      = tags("ubuntu-${ver}")
  platforms = PLATFORMS
  labels = {
    "org.opencontainers.image.title"       = "Ubuntu ${ver} base"
    "org.opencontainers.image.description" = "Didstopia base image for Ubuntu ${ver}"
  }
}

target "static-ubuntu" {
  inherits   = ["_common"]
  matrix     = { ver = UBUNTU_VERSIONS }
  name       = "static-ubuntu-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Ubuntu/static/Dockerfile"
  args       = { BASE_IMAGE = "${REGISTRY}:ubuntu-${ver}" }
  contexts   = { "${REGISTRY}:ubuntu-${ver}" = "target:ubuntu-${replace(ver, ".", "-")}" }
  tags       = tags("static-ubuntu-${ver}")
  platforms  = PLATFORMS
  labels = {
    "org.opencontainers.image.title"       = "Static hosting (nginx) on Ubuntu ${ver}"
    "org.opencontainers.image.description" = "nginx static hosting base image on Ubuntu ${ver}"
  }
}

target "nodejs-ubuntu" {
  inherits   = ["_common"]
  matrix     = { ver = UBUNTU_VERSIONS, node = NODE_VERSIONS }
  name       = "nodejs-${node}-ubuntu-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Ubuntu/nodejs/Dockerfile"
  args = {
    BASE_IMAGE = "${REGISTRY}:ubuntu-${ver}"
    NODE_MAJOR = node
  }
  contexts  = { "${REGISTRY}:ubuntu-${ver}" = "target:ubuntu-${replace(ver, ".", "-")}" }
  tags      = tags("nodejs-${node}-ubuntu-${ver}")
  platforms = PLATFORMS
  labels = {
    "org.opencontainers.image.title"       = "Node.js ${node} on Ubuntu ${ver}"
    "org.opencontainers.image.description" = "Node.js ${node} base image on Ubuntu ${ver}"
  }
}

target "steamcmd-ubuntu" {
  inherits   = ["_common"]
  matrix     = { ver = UBUNTU_VERSIONS }
  name       = "steamcmd-ubuntu-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Ubuntu/steamcmd/Dockerfile"
  args       = { BASE_IMAGE = "${REGISTRY}:ubuntu-${ver}" }
  contexts   = { "${REGISTRY}:ubuntu-${ver}" = "target:ubuntu-${replace(ver, ".", "-")}" }
  tags       = tags("steamcmd-ubuntu-${ver}")
  platforms  = ["linux/amd64"]
  labels = {
    "org.opencontainers.image.title"       = "SteamCMD on Ubuntu ${ver}"
    "org.opencontainers.image.description" = "SteamCMD base image on Ubuntu ${ver} (amd64 only)"
  }
}

target "nodejs-steamcmd-ubuntu" {
  inherits   = ["_common"]
  matrix     = { ver = UBUNTU_VERSIONS, node = NODE_VERSIONS }
  name       = "nodejs-${node}-steamcmd-ubuntu-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Ubuntu/nodejs-steamcmd/Dockerfile"
  args = {
    BASE_IMAGE = "${REGISTRY}:steamcmd-ubuntu-${ver}"
    NODE_MAJOR = node
  }
  contexts  = { "${REGISTRY}:steamcmd-ubuntu-${ver}" = "target:steamcmd-ubuntu-${replace(ver, ".", "-")}" }
  tags      = tags("nodejs-${node}-steamcmd-ubuntu-${ver}")
  platforms = ["linux/amd64"]
  labels = {
    "org.opencontainers.image.title"       = "Node.js ${node} + SteamCMD on Ubuntu ${ver}"
    "org.opencontainers.image.description" = "Node.js ${node} and SteamCMD base image on Ubuntu ${ver} (amd64 only)"
  }
}

# ----------------------------------------------------------------------------
# Alpine
# ----------------------------------------------------------------------------

target "alpine-base" {
  inherits   = ["_common"]
  matrix     = { ver = ALPINE_VERSIONS }
  name       = "alpine-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Alpine/Dockerfile"
  args       = { ALPINE_VERSION = ver }
  tags       = tags("alpine-${ver}")
  platforms  = PLATFORMS
  labels = {
    "org.opencontainers.image.title"       = "Alpine ${ver} base"
    "org.opencontainers.image.description" = "Didstopia base image for Alpine ${ver}"
  }
}

target "static-alpine" {
  inherits   = ["_common"]
  matrix     = { ver = ALPINE_VERSIONS }
  name       = "static-alpine-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Alpine/static/Dockerfile"
  args       = { BASE_IMAGE = "${REGISTRY}:alpine-${ver}" }
  contexts   = { "${REGISTRY}:alpine-${ver}" = "target:alpine-${replace(ver, ".", "-")}" }
  tags       = tags("static-alpine-${ver}")
  platforms  = PLATFORMS
  labels = {
    "org.opencontainers.image.title"       = "Static hosting (nginx) on Alpine ${ver}"
    "org.opencontainers.image.description" = "nginx static hosting base image on Alpine ${ver}"
  }
}

target "nodejs-alpine" {
  inherits   = ["_common"]
  matrix     = { ver = ALPINE_VERSIONS }
  name       = "nodejs-alpine-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Alpine/nodejs/Dockerfile"
  args       = { BASE_IMAGE = "${REGISTRY}:alpine-${ver}" }
  contexts   = { "${REGISTRY}:alpine-${ver}" = "target:alpine-${replace(ver, ".", "-")}" }
  tags       = tags("nodejs-alpine-${ver}")
  platforms  = PLATFORMS
  labels = {
    "org.opencontainers.image.title"       = "Node.js (distro LTS) on Alpine ${ver}"
    "org.opencontainers.image.description" = "Node.js base image on Alpine ${ver}"
  }
}

target "go-alpine" {
  inherits   = ["_common"]
  matrix     = { ver = ALPINE_VERSIONS }
  name       = "go-alpine-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Alpine/go/Dockerfile"
  args = {
    BASE_IMAGE = "${REGISTRY}:alpine-${ver}"
    GO_VERSION = GO_VERSION
  }
  contexts  = { "${REGISTRY}:alpine-${ver}" = "target:alpine-${replace(ver, ".", "-")}" }
  tags      = tags("go-alpine-${ver}")
  platforms = PLATFORMS
  labels = {
    "org.opencontainers.image.title"       = "Go on Alpine ${ver}"
    "org.opencontainers.image.description" = "Go toolchain base image on Alpine ${ver}"
  }
}

# ----------------------------------------------------------------------------
# Groups
# ----------------------------------------------------------------------------

group "default" {
  targets = [
    "ubuntu-base", "static-ubuntu", "nodejs-ubuntu", "steamcmd-ubuntu", "nodejs-steamcmd-ubuntu",
    "alpine-base", "static-alpine", "nodejs-alpine", "go-alpine",
  ]
}

group "ubuntu" {
  targets = ["ubuntu-base", "static-ubuntu", "nodejs-ubuntu", "steamcmd-ubuntu", "nodejs-steamcmd-ubuntu"]
}

group "alpine" {
  targets = ["alpine-base", "static-alpine", "nodejs-alpine", "go-alpine"]
}
