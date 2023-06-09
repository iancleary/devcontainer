# Copyright (c) Ian Cleary (he/him/his).
# Distributed under the terms of the MIT License.

# https://hub.docker.com/_/rust
ARG ROOT_CONTAINER=rust:alpine3.18

FROM $ROOT_CONTAINER

LABEL maintainer="Ian Cleary <github@iancleary.me>"
ARG CODE_USER="vscode"
ARG CODE_UID="1000"
ARG CODE_GID="1000"

# Install all OS dependencies
# https://pkgs.alpinelinux.org/packages?branch=v3.18

# Base packages
RUN apk add --no-cache \
    bash \
    build-base \
    curl \
    git \
    just \
    make \
    nano \
    openssh \
    wget \
    zsh && \
    bash --version && \
    curl --version && \
    git --version && \
    just --version && \
    make --version && \
    nano --version && \
    which ssh && \
    wget --version && \
    zsh --version

# NodeJS and NPM
RUN apk add --no-cache \
    nodejs \
    npm && \
    node --version && \
    npm --version

# Python3 and pip
RUN apk add --no-cache \
    python3 \
    python3-dev \
    py3-pip \
    bash && \
    python3 --version && \
    pip --version

# # Create CODE_USER with name jovyan user with UID=1000 and in the 'users' group
# # and make sure these dirs are writable by the `users` group.
RUN adduser -u "${CODE_UID}" "${CODE_USER}" --disabled-password

# Setup home directory and path
ENV PATH="/home/${CODE_USER}/.local/bin:${PATH}" \
    HOME="/home/${CODE_USER}"

###
# ensure image runs as unpriveleged user by default.
###
USER ${CODE_USER}

# Upgrade pip, install pipx, and use pipx to install pre-commit and pdm 
RUN python3.11 -m pip install --user --upgrade --no-cache-dir pip && \
    python3.11 -m pip install --user --no-cache-dir pipx && \
    # pipx path
    python3.11 -m pipx ensurepath --force && \
    # pipx packages
    # I generally like to contain development tools inside
    # a pre-commit config file, or a pdm project .venv
    pipx install pre-commit && \
    pipx install pdm 

# install oh-my-zsh, plugins, and themes
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    mkdir -p ~/.oh-my-zsh/custom/plugins && \
    mkdir -p ~/.oh-my-zsh/custom/themes && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k && \
    git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/fast-syntax-highlighting && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

# My preferences (copy over them if you want)
COPY custom/.zshrc custom/.zshrc_aliases custom/.p10k.zsh /home/${CODE_USER}/

# set default shell after all other installation steps are done
ENV SHELL=/usr/bin/zsh

###
# ensure image runs as unpriveleged user by default.
###
USER ${CODE_USER}
