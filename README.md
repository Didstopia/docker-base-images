# Base images for Docker that are always up to date

[![Build](https://github.com/Didstopia/docker-base-images/actions/workflows/build.yml/badge.svg)](https://github.com/Didstopia/docker-base-images/actions/workflows/build.yml)
[![Publish](https://github.com/Didstopia/docker-base-images/actions/workflows/publish.yml/badge.svg)](https://github.com/Didstopia/docker-base-images/actions/workflows/publish.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/didstopia/base.svg)](https://hub.docker.com/r/didstopia/base/)

These are the base images everything at Didstopia builds on top of. They are
rebuilt nightly so OS and package security updates flow through automatically,
then pushed to Docker Hub (and mirrored to GHCR).

All published tags live on the [Docker Hub page](https://hub.docker.com/r/didstopia/base/).

## Images

Built from Ubuntu 22.04 / 24.04 and the two newest Alpine stable lines plus
edge. Tags follow `[<variant>-]<os>-<version>`.

| Image            | Example tags                                                        | Platforms      |
|------------------|---------------------------------------------------------------------|----------------|
| base             | `ubuntu-24.04`, `ubuntu-22.04`, `alpine-3.23`, `alpine-edge`         | amd64, arm64   |
| static (nginx)   | `static-ubuntu-24.04`, `static-alpine-3.23`                          | amd64, arm64   |
| Node.js          | `nodejs-22-ubuntu-24.04`, `nodejs-24-ubuntu-24.04`, `nodejs-alpine-3.23` | amd64, arm64 |
| Go               | `go-alpine-3.23`                                                     | amd64, arm64   |
| SteamCMD         | `steamcmd-ubuntu-24.04`                                              | amd64 only     |
| Node.js + SteamCMD | `nodejs-22-steamcmd-ubuntu-24.04`                                  | amd64 only     |

Node.js on Ubuntu comes from NodeSource and is pinned to 22 or 24. Node.js on
Alpine is the distro's current LTS. SteamCMD is a 32-bit x86 binary with no
arm64 build, so those two images are amd64 only.

Every image runs as a non-root `docker` user (uid/gid 1000) via an entrypoint
that remaps to `PUID`/`PGID` and drops privileges with gosu (su-exec on Alpine).

## Usage

```dockerfile
FROM didstopia/base:nodejs-24-ubuntu-24.04
# your app on top
```

Common runtime variables: `PUID`, `PGID`, `TZ`, `CHOWN_DIRS`,
`ENABLE_PASSWORDLESS_SUDO`.

## Building

The whole image graph is defined in [`docker-bake.hcl`](docker-bake.hcl) and
built with `docker buildx bake`. Variant images pull their base through bake's
`contexts` wiring, so the entire graph builds in dependency order in one call
with no intermediate pushes.

```sh
# Build everything (build cache only)
docker buildx bake

# Build a group or a single target
docker buildx bake ubuntu
docker buildx bake nodejs-ubuntu

# Build one target for the local arch and load it, then smoke test
docker buildx bake ubuntu-24-04 --set "*.platform=linux/arm64" --load
./Scripts/test/smoke.sh
```

Versions can be overridden from the environment (comma-separated), for example
`NODE_VERSIONS=24 docker buildx bake nodejs-ubuntu`.

> SteamCMD targets are amd64 only and can't be built on an arm64 host (the
> 32-bit binary won't run under nested emulation). Build them on amd64 or let CI
> handle it.

## Automation

- **Native multi-arch builds.** Each architecture builds on its own native
  runner (amd64 on `ubuntu-latest`, arm64 on `ubuntu-24.04-arm`), then the
  per-arch images are merged into one manifest. No QEMU emulation, which is both
  faster and avoids the emulation segfaults. Build layers are cached in a GHCR
  cache repo so unchanged layers are not rebuilt.
- **Daily rebuild** ([publish.yml](.github/workflows/publish.yml)) checks the
  upstream base image digests and rebuilds only the OS lines that actually
  changed, so security updates land without churning every tag every night. A
  weekly run rebuilds everything unconditionally (no cache) as a backstop for
  package updates that land before the base is re-tagged.
- **Build gate** ([build.yml](.github/workflows/build.yml)) lints with hadolint,
  builds the graph on both arches, runs the smoke tests and scans with Trivy on
  every PR.
- **Docker Scout** continuously monitors the published images for new CVEs and
  base image drift; Trivy results also go to GitHub code scanning.
- **Dependabot** keeps the GitHub Actions current, with patch/minor updates
  auto-merged once CI passes.
- **Downstream images** rebuild themselves when the base changes, via the
  reusable workflow at `.github/workflows/downstream.yml` and the
  `.github/actions/base-image-changed` action.

## Licenses

Provided under the [MIT License](https://github.com/Didstopia/docker-base-images/blob/master/LICENSE.md).
