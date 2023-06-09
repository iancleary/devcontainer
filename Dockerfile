# Copyright (c) Ian Cleary (he/him/his).
# Distributed under the terms of the MIT License.

# Inspiration for this Dockerfile pattern comes from the following sources:
# # https://github.com/jupyter/docker-stacks/blob/main/docker-stacks-foundation/Dockerfile
# # Copyright (c) Jupyter Development Team.
# # Distributed under the terms of the Modified BSD License.

# Ubuntu 22.04 (jammy)
# https://hub.docker.com/_/ubuntu/tags?page=1&name=jammy
ARG ROOT_CONTAINER=ubuntu:22.04

FROM $ROOT_CONTAINER

LABEL maintainer="Ian Cleary <github@iancleary.master>"
ARG CODE_USER="vscode"
ARG CODE_UID="1000"
ARG CODE_GID="100"

USER root

# Install all OS dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends \
    # - apt-get upgrade is run to patch known vulnerabilities in apt-get packages as
    #   the ubuntu base image is rebuilt too seldom sometimes (less than once a month)
    # Common useful utilities
    git \
    nano-tiny \
    tzdata \
    unzip \
    vim-tiny \
    # git-over-ssh
    openssh-client \
    # font for powerline10k
    fontconfig \
    # Terminal Customization
    zsh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PATH="/home/${NB_USER}/.local/bin:${PATH}" \
    HOME="/home/${NB_USER}"

# Copy a script that we will use to correct permissions after running certain commands
COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions

# Create CODE_USER with name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
    useradd -l -m -s /bin/bash -N -u "${CODE_UID}" "${CODE_USER}" && \
    chmod g+w /etc/passwd && \
    fix-permissions "${HOME}"

# Create alternative for nano -> nano-tiny
RUN update-alternatives --install /usr/bin/nano nano /bin/nano-tiny 10

# Switch back to jovyan to avoid accidental container runs as root
USER ${CODE_UID}

## Oh My ZSH and Powerlevel10k
## See https://github.com/iancleary/ansible-role-ohmyzsh
USER $CODE_UID
# run the installation script
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k && \
    git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/fast-syntax-highlighting && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    mkdir -p ~/.local/share/fonts/ && \
    cd ~/.local/share/fonts/ && \
    wget -O 'MesloLGS NF Regular.ttf' https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf && \
    wget -O 'MesloLGS NF Bold.ttf' https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf && \
    wget -O 'MesloLGS NF Italic.ttf' https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf && \
    wget -O 'MesloLGS NF Bold Italic.ttf' https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf && \
    fc-cache -f -v

COPY custom/.zshrc custom/.zshrc_aliases custom/.p10k.zsh /home/${CODE_USER}/

USER root

# Fix permissions on custom files and files needed to set overrides
RUN fix-permissions "/home/${CODE_USER}/.local/share/fonts" && \
    fix-permissions "/home/${CODE_USER}/.zshrc" && \
    fix-permissions "/home/${CODE_USER}/.zshrc_aliases" && \
    fix-permissions "/home/${CODE_USER}/.p10k.zsh"

USER ${CODE_UID}

## Pip and Python Packages
RUN pip install --upgrade pip

# set default shell
ENV SHELL=/usr/bin/zsh

WORKDIR "${HOME}"
###
# ensure image runs as unpriveleged user by default.
###
USER ${CODE_UID}
