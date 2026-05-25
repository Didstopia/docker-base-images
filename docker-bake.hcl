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
# Versions can be overridden from the environment (comma-separated), e.g.:
#   NODE_VERSIONS=24 docker buildx bake nodejs-ubuntu
#   UBUNTU_VERSIONS=24.04 ALPINE_VERSIONS=3.23 docker buildx bake

variable "REGISTRY" {
  default = "didstopia/base"
}

# Second registry to also tag (e.g. ghcr.io/didstopia/base). Empty disables it,
# so local builds only produce didstopia/base tags. CI sets this.
variable "GHCR_REGISTRY" {
  default = ""
}

# Registry for the build-layer cache (e.g. ghcr.io/didstopia/base-buildcache).
# Empty disables caching entirely. Reading cache is safe everywhere; writing it
# is gated on CACHE_WRITE so only the publish workflow exports cache, while PR
# builds read it but never write. See the cache_from/cache_to functions below.
variable "CACHE_REPO" {
  default = ""
}

variable "CACHE_WRITE" {
  default = "false"
}

# Suffix appended to every cache ref. The native per-arch publish builds set this
# to "-amd64" / "-arm64" so the two runners don't overwrite each other's cache.
variable "CACHE_SUFFIX" {
  default = ""
}

variable "GOSU_VERSION" {
  default = "1.19"
}

# Empty means the Go image tracks the latest stable release at build time.
variable "GO_VERSION" {
  default = ""
}

# Comma-separated, not HCL lists, so they can be overridden from the environment
# (bake won't coerce a JSON-array env string into a tuple-typed variable). They
# are split() into lists where they feed the matrices below.
variable "UBUNTU_VERSIONS" {
  default = "22.04,24.04"
}

variable "ALPINE_VERSIONS" {
  default = "3.22,3.23,edge"
}

variable "NODE_VERSIONS" {
  default = "22,24"
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

# Per-image build cache refs in CACHE_REPO. cache_from is safe to leave on
# everywhere: a miss (or an unreachable cache) just builds cold. cache_to only
# exports when CACHE_WRITE is "true" (set by the publish workflow), so PR builds
# read the cache without polluting it. mode=max caches intermediate layers too,
# which matters for the base->variant chains; oci-mediatypes + image-manifest
# keep the cache format compatible with GHCR.
function "cache_from" {
  params = [name]
  result = CACHE_REPO != "" ? ["type=registry,ref=${CACHE_REPO}:${name}${CACHE_SUFFIX}"] : []
}

function "cache_to" {
  params = [name]
  result = (CACHE_REPO != "" && CACHE_WRITE == "true") ? ["type=registry,ref=${CACHE_REPO}:${name}${CACHE_SUFFIX},mode=max,oci-mediatypes=true,image-manifest=true"] : []
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
  matrix     = { ver = split(",", UBUNTU_VERSIONS) }
  name       = "ubuntu-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Ubuntu/Dockerfile"
  args = {
    UBUNTU_VERSION = ver
    GOSU_VERSION   = GOSU_VERSION
  }
  tags       = tags("ubuntu-${ver}")
  cache-from = cache_from("ubuntu-${ver}")
  cache-to   = cache_to("ubuntu-${ver}")
  platforms = PLATFORMS
  labels = {
    "org.opencontainers.image.title"       = "Ubuntu ${ver} base"
    "org.opencontainers.image.description" = "Didstopia base image for Ubuntu ${ver}"
  }
}

target "static-ubuntu" {
  inherits   = ["_common"]
  matrix     = { ver = split(",", UBUNTU_VERSIONS) }
  name       = "static-ubuntu-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Ubuntu/static/Dockerfile"
  args       = { BASE_IMAGE = "${REGISTRY}:ubuntu-${ver}" }
  contexts   = { "${REGISTRY}:ubuntu-${ver}" = "target:ubuntu-${replace(ver, ".", "-")}" }
  tags       = tags("static-ubuntu-${ver}")
  cache-from = cache_from("static-ubuntu-${ver}")
  cache-to   = cache_to("static-ubuntu-${ver}")
  platforms  = PLATFORMS
  labels = {
    "org.opencontainers.image.title"       = "Static hosting (nginx) on Ubuntu ${ver}"
    "org.opencontainers.image.description" = "nginx static hosting base image on Ubuntu ${ver}"
  }
}

target "nodejs-ubuntu" {
  inherits   = ["_common"]
  matrix     = { ver = split(",", UBUNTU_VERSIONS), node = split(",", NODE_VERSIONS) }
  name       = "nodejs-${node}-ubuntu-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Ubuntu/nodejs/Dockerfile"
  args = {
    BASE_IMAGE = "${REGISTRY}:ubuntu-${ver}"
    NODE_MAJOR = node
  }
  contexts  = { "${REGISTRY}:ubuntu-${ver}" = "target:ubuntu-${replace(ver, ".", "-")}" }
  tags       = tags("nodejs-${node}-ubuntu-${ver}")
  cache-from = cache_from("nodejs-${node}-ubuntu-${ver}")
  cache-to   = cache_to("nodejs-${node}-ubuntu-${ver}")
  platforms = PLATFORMS
  labels = {
    "org.opencontainers.image.title"       = "Node.js ${node} on Ubuntu ${ver}"
    "org.opencontainers.image.description" = "Node.js ${node} base image on Ubuntu ${ver}"
  }
}

target "steamcmd-ubuntu" {
  inherits   = ["_common"]
  matrix     = { ver = split(",", UBUNTU_VERSIONS) }
  name       = "steamcmd-ubuntu-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Ubuntu/steamcmd/Dockerfile"
  args       = { BASE_IMAGE = "${REGISTRY}:ubuntu-${ver}" }
  contexts   = { "${REGISTRY}:ubuntu-${ver}" = "target:ubuntu-${replace(ver, ".", "-")}" }
  tags       = tags("steamcmd-ubuntu-${ver}")
  cache-from = cache_from("steamcmd-ubuntu-${ver}")
  cache-to   = cache_to("steamcmd-ubuntu-${ver}")
  platforms  = ["linux/amd64"]
  labels = {
    "org.opencontainers.image.title"       = "SteamCMD on Ubuntu ${ver}"
    "org.opencontainers.image.description" = "SteamCMD base image on Ubuntu ${ver} (amd64 only)"
  }
}

target "nodejs-steamcmd-ubuntu" {
  inherits   = ["_common"]
  matrix     = { ver = split(",", UBUNTU_VERSIONS), node = split(",", NODE_VERSIONS) }
  name       = "nodejs-${node}-steamcmd-ubuntu-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Ubuntu/nodejs-steamcmd/Dockerfile"
  args = {
    BASE_IMAGE = "${REGISTRY}:steamcmd-ubuntu-${ver}"
    NODE_MAJOR = node
  }
  contexts  = { "${REGISTRY}:steamcmd-ubuntu-${ver}" = "target:steamcmd-ubuntu-${replace(ver, ".", "-")}" }
  tags       = tags("nodejs-${node}-steamcmd-ubuntu-${ver}")
  cache-from = cache_from("nodejs-${node}-steamcmd-ubuntu-${ver}")
  cache-to   = cache_to("nodejs-${node}-steamcmd-ubuntu-${ver}")
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
  matrix     = { ver = split(",", ALPINE_VERSIONS) }
  name       = "alpine-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Alpine/Dockerfile"
  args       = { ALPINE_VERSION = ver }
  tags       = tags("alpine-${ver}")
  cache-from = cache_from("alpine-${ver}")
  cache-to   = cache_to("alpine-${ver}")
  platforms  = PLATFORMS
  labels = {
    "org.opencontainers.image.title"       = "Alpine ${ver} base"
    "org.opencontainers.image.description" = "Didstopia base image for Alpine ${ver}"
  }
}

target "static-alpine" {
  inherits   = ["_common"]
  matrix     = { ver = split(",", ALPINE_VERSIONS) }
  name       = "static-alpine-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Alpine/static/Dockerfile"
  args       = { BASE_IMAGE = "${REGISTRY}:alpine-${ver}" }
  contexts   = { "${REGISTRY}:alpine-${ver}" = "target:alpine-${replace(ver, ".", "-")}" }
  tags       = tags("static-alpine-${ver}")
  cache-from = cache_from("static-alpine-${ver}")
  cache-to   = cache_to("static-alpine-${ver}")
  platforms  = PLATFORMS
  labels = {
    "org.opencontainers.image.title"       = "Static hosting (nginx) on Alpine ${ver}"
    "org.opencontainers.image.description" = "nginx static hosting base image on Alpine ${ver}"
  }
}

target "nodejs-alpine" {
  inherits   = ["_common"]
  matrix     = { ver = split(",", ALPINE_VERSIONS) }
  name       = "nodejs-alpine-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Alpine/nodejs/Dockerfile"
  args       = { BASE_IMAGE = "${REGISTRY}:alpine-${ver}" }
  contexts   = { "${REGISTRY}:alpine-${ver}" = "target:alpine-${replace(ver, ".", "-")}" }
  tags       = tags("nodejs-alpine-${ver}")
  cache-from = cache_from("nodejs-alpine-${ver}")
  cache-to   = cache_to("nodejs-alpine-${ver}")
  platforms  = PLATFORMS
  labels = {
    "org.opencontainers.image.title"       = "Node.js (distro LTS) on Alpine ${ver}"
    "org.opencontainers.image.description" = "Node.js base image on Alpine ${ver}"
  }
}

target "go-alpine" {
  inherits   = ["_common"]
  matrix     = { ver = split(",", ALPINE_VERSIONS) }
  name       = "go-alpine-${replace(ver, ".", "-")}"
  dockerfile = "Dockerfiles/Alpine/go/Dockerfile"
  args = {
    BASE_IMAGE = "${REGISTRY}:alpine-${ver}"
    GO_VERSION = GO_VERSION
  }
  contexts  = { "${REGISTRY}:alpine-${ver}" = "target:alpine-${replace(ver, ".", "-")}" }
  tags       = tags("go-alpine-${ver}")
  cache-from = cache_from("go-alpine-${ver}")
  cache-to   = cache_to("go-alpine-${ver}")
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

# Ubuntu targets that build for every platform (steamcmd is amd64 only and is
# excluded). The arm64 native runner builds this group instead of "ubuntu".
group "ubuntu-multiarch" {
  targets = ["ubuntu-base", "static-ubuntu", "nodejs-ubuntu"]
}

group "alpine" {
  targets = ["alpine-base", "static-alpine", "nodejs-alpine", "go-alpine"]
}
