## Based on https://github.com/myoung34/docker-github-actions-runner/blob/clair/Dockerfile

# Base image
FROM didstopia/base:ubuntu-18.04

# Maintainer information
LABEL maintainer="Didstopia <support@didstopia.com>"

# Override the default shell
SHELL ["/bin/bash", "-e", "-o", "pipefail", "-c"]

# Disable TTY interaction
ARG DEBIAN_FRONTEND=noninteractive

# Default ghrunner version and platform
ARG GH_RUNNER_VERSION="2.267.1"
ARG GH_RUNNER_PLATFORM

# Default git version
ARG GIT_VERSION="2.27.0"

# Default Docker Compose version
ARG DOCKER_COMPOSE_VERSION="1.26.2"

# Define directories to take ownership of
ENV CHOWN_DIRS "/app"

# Install various dependencies for build environments
RUN apt-get update  \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
    awscli \
    curl \
    tar \
    apt-transport-https \
    ca-certificates \
    sudo \
    gnupg-agent \
    software-properties-common \
    build-essential \
    zlib1g-dev \
    gettext \
    liblttng-ust0 \
    libcurl4-openssl-dev \
    inetutils-ping \
    jq \
    unbuffer \
  && rm -rf /var/lib/apt/lists/* \
  && c_rehash \
  && cd /tmp \
  && curl -sL https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz -o git.tgz \
  && tar zxf git.tgz \
  && cd git-${GIT_VERSION} \
  && ./configure --prefix=/usr \
  && make \
  && make install \
  && cd / \
  && rm -rf /tmp/git.tgz /tmp/git-${GIT_VERSION}

# Install Docker support
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
  && [[ $(lsb_release -cs) == "eoan" ]] && ( add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu disco stable" ) || ( add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" )\
  && apt-get update \
  && apt-get install -y docker-ce docker-ce-cli containerd.io --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

# Install Docker Compose
RUN curl -sL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

# Set the default working directory
WORKDIR /app

# Install the GitHub Actions runner
ADD Scripts/ghrunner/install.sh /app
RUN chmod +x /app/install.sh \
  && /app/install.sh ${GH_RUNNER_VERSION} ${GH_RUNNER_PLATFORM} \
  && rm /app/install.sh

# Add the ghrunner token generation script
COPY Scripts/ghrunner/token.sh /
RUN chmod +x /token.sh

# Add the ghrunner entrypoint
ADD Scripts/ghrunner/entrypoint.sh /entrypoint_ghrunner.sh
RUN chmod +x /entrypoint_ghrunner.sh

# Run the ghrunner entrypoint script as the default command (acts as an additional entrypoint)
CMD ["/bin/bash", "/entrypoint_ghrunner.sh"]
