# Base images for Docker that are always up to date

**NOTE:** This is still a work in progress.

These images are automatically built, tested and pushed on a daily basis, so they're always up to date.

---

## Development

Create an alias for `docker-make` as an optional convenience:
```sh
alias docker-make="docker run --rm -w /usr/src/app\\
                                   -v ~/.docker:/root/.docker\\
                                   -v /var/run/docker.sock:/var/run/docker.sock\\
                                   -v \"\$(pwd)\":/usr/src/app jizhilong/docker-make docker-make"
```

Build the images:
```sh
docker-make --no-push
```

## Licenses

This project is provided under the [MIT License](https://github.com/Didstopia/docker-base-images/blob/master/LICENSE.md).
