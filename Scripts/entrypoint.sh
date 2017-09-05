#!/bin/bash

# Enable error handling
set -e

# Set the current timezone
ln -snf "/usr/share/zoneinfo/${TZ}" "/etc/localtime"
echo "${TZ}" > "/etc/timezone"

# Set the group and user identifiers
groupmod --non-unique --gid "${PGID}" docker &> /dev/null
usermod --non-unique --uid "${PUID}" docker &> /dev/null

# Set the correct permissions
chown docker:docker /app

# Continue execution
exec gosu docker "$@"
