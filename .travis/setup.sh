#!/bin/bash

# Catch errors
set -e
set -o pipefail

# Switch to root
cd "${0%/*}"/../

# Setup the repo for deployment
git remote set-url origin $GITHUB_REPO
git config --global user.email "builds@travis-ci.com"
git config --global user.name "Travis CI"

# Login to Docker Hub
docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
