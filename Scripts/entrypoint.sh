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

# Show a disclaimer
echo "
╔═════════════════════════════════════════════════╗
║    _____  _     _     _              _          ║
║   |  __ \(_)   | |   | |            (_)         ║
║   | |  | |_  __| |___| |_ ___  _ __  _  __ _    ║
║   | |  | | |/ _| / __| __/ _ \| |_ \| |/ _| |   ║
║   | |__| | | (_| \__ \ || (_) | |_) | | (_| |   ║
║   |_____/|_|\__|_|___/\__\___/| |__/|_|\__|_|   ║
║                               | |               ║
║                               |_|               ║
╠═════════════════════════════════════════════════╣
║ You are using an image that is based on         ║
║ a base image maintained by Didstopia.           ║
║                                                 ║
║ For more information:                           ║
║ https://github.com/Didstopia/docker-base-images ║
╚═════════════════════════════════════════════════╝
"

# Continue execution
exec gosu docker "$@"
