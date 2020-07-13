#!/usr/bin/env bash

# Enable error handling
set -e

# Enable debugging
#set -x

# Set the current timezone
ln -snf "/usr/share/zoneinfo/${TZ}" "/etc/localtime"
echo "${TZ}" > "/etc/timezone"

# Set the group and user identifiers
groupmod --non-unique --gid ${PGID} docker &> /dev/null
usermod --non-unique --uid ${PUID} docker &> /dev/null

# Add the user to the tty group (fixes permission issues with /dev/std* etc.)
usermod -a -G tty docker &> /dev/null

# Set the correct permissions
for path in ${CHOWN_DIRS//,/ }
do
  chown -R docker:docker "${path}"
done

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
#exec gosu ${PUID}:${PGID} "$@"
exec gosu docker "$@"
