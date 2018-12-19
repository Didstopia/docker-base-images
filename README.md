# Base images for Docker that are always up to date

[![Build Status](https://travis-ci.org/Didstopia/docker-base-images.svg?branch=master)](https://travis-ci.org/Didstopia/docker-base-images)

These images are automatically built, tested and pushed on a daily basis, so they're always up to date.

To see all the available images, please go to [this Docker Hub page](https://hub.docker.com/r/didstopia/base/).

---

## Development

Build the images (Alpine used as an example):
```sh
./docker-make.sh --no-push --remove --detailed --file .docker-make.alpine-3-5.yml
```

Check the `.travis` folder for scripts used for checking updates, testing etc.

## Licenses

This project is provided under the [MIT License](https://github.com/Didstopia/docker-base-images/blob/master/LICENSE.md).
