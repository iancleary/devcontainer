# Copyright (c) Ian Cleary (he/him/his).
# Distributed under the terms of the MIT License.

# https://hub.docker.com/_/alpine
ARG ROOT_CONTAINER=alpine:3.18

# PERHAPS USE RUST'S ALPINE IMAGE INSTEAD?

FROM $ROOT_CONTAINER

LABEL maintainer="Ian Cleary <github@iancleary.me>"
ARG CODE_USER="vscode"
ARG CODE_UID="1000"
ARG CODE_GID="1000"


# Install all OS dependencies
# https://pkgs.alpinelinux.org/packages?branch=v3.18

RUN apk add --no-cache \
    curl \
    git \
    make \
    nano \
    openssh \
    wget \
    zsh

RUN apk add --no-cache \
    nodejs \
    npm

RUN apk add --no-cache \
    cargo \
    rust

# Install cargo crates
RUN cargo install just && \
    cargo install sd

RUN apk add --no-cache \
    python3 \
    python3-dev \
    py3-pip \
    bash

# # Create CODE_USER with name jovyan user with UID=1000 and in the 'users' group
# # and make sure these dirs are writable by the `users` group.
RUN adduser -u "${CODE_UID}" "${CODE_USER}" --disabled-password


ENV PATH="/home/${CODE_USER}/.local/bin:${PATH}" \
#     PATH="/home/${CODE_USER}/.cargo/bin:${PATH}" \
    HOME="/home/${CODE_USER}"

# ###
# # ensure image runs as unpriveleged user by default.
# ###
USER ${CODE_USER}

# Upgrade pip, install pipx, and pipx install pre-commit and pdm
# I generally like to contain development tools inside
# a pre-commit config file, or a pdm project .venv
RUN python3.11 -m pip install --user --upgrade --no-cache-dir pip && \
    python3.11 -m pip install --user --no-cache-dir pipx && \
    python3.11 -m pipx ensurepath --force && \
    pipx install pre-commit && \
    pipx install pdm

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    mkdir -p ~/.oh-my-zsh/custom/plugins && \
    mkdir -p ~/.oh-my-zsh/custom/themes && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k && \
    git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/fast-syntax-highlighting && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
#     # mkdir -p ~/.local/share/fonts && \
#     # cd ~/.local/share/fonts && \
#     # wget -O 'MesloLGS NF Regular.ttf' https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf && \
#     # wget -O 'MesloLGS NF Bold.ttf' https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf && \
#     # wget -O 'MesloLGS NF Italic.ttf' https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf && \
#     # wget -O 'MesloLGS NF Bold Italic.ttf' https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf && \
#     # fc-cache -f -v

COPY custom/.zshrc custom/.zshrc_aliases custom/.p10k.zsh /home/${CODE_USER}/

# # set default shell after all other installation steps are done
ENV SHELL=/usr/bin/zsh

###
# ensure image runs as unpriveleged user by default.
###
USER ${CODE_USER}
