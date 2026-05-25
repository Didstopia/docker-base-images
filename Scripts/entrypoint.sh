#!/usr/bin/env bash

# Enable error handling
set -e

# Enable debugging
# set -x

# Set the current timezone
ln -snf "/usr/share/zoneinfo/${TZ}" "/etc/localtime"
echo "${TZ}" > "/etc/timezone"

# Set the group and user identifiers
groupmod --non-unique --gid ${PGID} docker &> /dev/null
usermod --non-unique --uid ${PUID} docker &> /dev/null

# Add the user to the tty group (fixes permission issues with /dev/std* etc.)
usermod -a -G tty docker &> /dev/null

# Create the steamcmd symlink and scratch dir if steamcmd is present.
# Covers both the /steamcmd tarball install and the distro package.
if [ -x "/steamcmd/steamcmd.sh" ]; then
  ln -sf "/steamcmd/steamcmd.sh" "/usr/local/bin/steamcmd"
  mkdir -p /tmp/dumps
  chown -R "${PUID}":"${PGID}" /tmp/dumps
elif [ -f "/usr/games/steamcmd" ]; then
  ln -sf "/usr/games/steamcmd" "/usr/local/bin/steamcmd"
  mkdir -p /tmp/dumps
  chown -R "${PUID}":"${PGID}" /tmp/dumps
fi

# Check if we should enable passwordless sudo. Only attempt this when sudo is
# actually installed, so it stays a no-op on the slim Alpine images.
if [ "${ENABLE_PASSWORDLESS_SUDO}" = "true" ] && command -v sudo > /dev/null && [ -f /etc/sudoers ]; then
  # Add the user to the sudo group
  if ! groups docker | grep -q "\bsudo\b"; then
    usermod -a -G sudo docker &> /dev/null
  fi

  # Allow sudo group uses to run sudo without specifying a password
  sed -i /etc/sudoers -re 's/^%sudo.*/%sudo   ALL=(ALL:ALL) NOPASSWD: ALL/g'

  # Handle Docker socket permissions if necessary
  DOCKER_SOCKET=/var/run/docker.sock
  if [ -S ${DOCKER_SOCKET} ]; then
    DOCKER_GID=$(stat -c '%g' ${DOCKER_SOCKET})
    if ! groups docker | grep -q "\b${DOCKER_GID}\b"; then
      usermod -a -G ${DOCKER_GID} docker &> /dev/null
    fi
  fi
fi

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

# Continue execution as the docker user
exec gosu docker "$@"
