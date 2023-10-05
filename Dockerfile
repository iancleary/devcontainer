# Copyright (c) Ian Cleary (he/him/his).
# Distributed under the terms of the MIT License.

# https://hub.docker.com/_/alpine/
ARG ROOT_CONTAINER=alpine:3.18
ARG NIX_INSTALLER_VERSION="v0.13.1"

FROM $ROOT_CONTAINER

LABEL maintainer="Ian Cleary <github@iancleary.me>"
ARG USER="root"

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

# Nix and direnv
## https://determinate.systems/posts/nix-direnv
## https://direnv.net/
## https://github.com/DeterminateSystems/nix-installer#the-determinate-nix-installer

RUN apk add --no-cache \
    direnv && \ 
    direnv --version

RUN curl --proto '=https' --tlsv1.2 -sSf -L "https://install.determinate.systems/nix/tag/${VERSION}" | sh -s -- install \
    --extra-conf "sandbox = false" \
    --init none \
    --no-confirm

# RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux \
#   --extra-conf "sandbox = false" \
#   --init none \
#   --no-confirm

ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"

# Debug: confirm during build nix works
RUN nix run nixpkgs#hello

# Setup home directory and path
ENV PATH="/home/${USER}/.local/bin:${PATH}" \
    PATH="/home/${USER}/.cargo/bin:${PATH}" \
    HOME="/home/${USER}"

# install oh-my-zsh, plugins, and themes
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    mkdir -p ~/.oh-my-zsh/custom/plugins && \
    mkdir -p ~/.oh-my-zsh/custom/themes && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k && \
    git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/fast-syntax-highlighting && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

# My preferences (copy over them if you want)
COPY custom/.zshrc custom/.zshrc_aliases custom/.p10k.zsh /home/${USER}/

# set default shell after all other installation steps are done
ENV SHELL=/usr/bin/zsh

# https://determinate.systems/posts/nix-direnv
#https://direnv.net/docs/installation.html
ENTRYPOINT [ "direnv allow" ]