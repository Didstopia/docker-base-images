# Base images for Docker that are always up to date
[![Docker Automated build](https://img.shields.io/docker/automated/didstopia/base.svg)](https://hub.docker.com/r/didstopia/base/)
[![Docker build status](https://img.shields.io/docker/build/didstopia/base.svg)](https://hub.docker.com/r/didstopia/base/)
[![Docker Pulls](https://img.shields.io/docker/pulls/didstopia/base.svg)](https://hub.docker.com/r/didstopia/base/)
[![Docker stars](https://img.shields.io/docker/stars/didstopia/base.svg)](https://hub.docker.com/r/didstopia/base)

[![Build Status](https://travis-ci.org/Didstopia/docker-base-images.svg?branch=master)](https://travis-ci.org/Didstopia/docker-base-images)

These images are automatically built, tested and pushed on a daily basis, so they're always up to date.

To see all the available images, please go to [this Docker Hub page](https://hub.docker.com/r/didstopia/base/).

---

## Development

### Basic

Build the images (Alpine used as an example):
```sh
./docker-make.sh --no-push --remove --detailed --file .docker-make.alpine-3-5.yml
```

Check the `.travis` folder for scripts used for checking updates, testing etc.

### Advanced

1. Pull and tag latest images from Docker Hub
> ./.ci/setup.sh

2. Check for updates to all images (statuses are exported as env vars)
> source .ci/update_check.sh

3. Build all images that have been marked for updating
> ./.ci/build.sh

4. Test the base images that they still work (note: requires `expect` to be installed)
> unbuffer .ci/test.sh

5. Push updated images to Docker Hub
> ./.ci/push.sh

Alternatively you can use `act`:
> act -W .github/workflows/test_docker.yml -s DOCKER_USERNAME=<user> -s DOCKER_PASSWORD=<password> --verbose -P ubuntu-latest=catthehacker/ubuntu:runner-20.04

## Licenses

This project is provided under the [MIT License](https://github.com/Didstopia/docker-base-images/blob/master/LICENSE.md).
