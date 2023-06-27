# devcontainer docker image

<!-- markdownlint-disable MD033 -->
<p align="center">
    <em>Container meant to be used in a devcontainer.json file within Visual Studio Code</em>
</p>

<p align="center">
<a href="https://github.com/iancleary/devcontainer/actions/workflows/publish.yml" target="_blank">
    <img src="https://github.com/iancleary/devcontainer/actions/workflows/publish.yml/badge.svg?event=release" alt="Publish Workflow status on Release event">
</a>
</p>
<!-- markdownlint-enable MD033 -->

Images are built and pushed to DockerHub and GitHub container registery automatically on releases.

## Devcontainer

> The Visual Studio Code Dev Containers extension lets you use a Docker container as a full-featured development environment. It allows you to open any folder or repository inside a container and take advantage of Visual Studio Code's full feature set. A devcontainer.json file in your project tells VS Code how to access (or create) a development container with a well-defined tool and runtime stack. This container can be used to run an application or to provide separate tools, libraries, or runtimes needed for working with a codebase

<https://code.visualstudio.com/docs/devcontainers/create-dev-container>

## Custom Preferences

I installed ohmyzsh, along with powerlevel10k, and the MesloLGS NF fonts in the [Dockerfile](./Dockerfile).

## .devcontainer/devcontainer.json

As is, with no configuration

```json
{
  "image": "ghcr.io/iancleary/devcontainer:latest",
  "remoteUser": "vscode"
}
```

With a Dockerfile in the `.devcontainer` folder

```json
{
  "build": {
    "dockerfile": "Dockerfile"
  },
  "remoteUser": "vscode"
}
```

With a Dockerfile in the root of the project

```json
{
  "build": {
    "dockerfile": "../Dockerfile"
  },
  "remoteUser": "vscode"
}
```

Dockerfile contents, if customizing:

```Dockerfile
FROM ghcr.io/iancleary/devcontainer:latest

USER root

# install development packages
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends \
    # - apt-get upgrade is run to patch known vulnerabilities in apt-get packages as
    #   the ubuntu base image is rebuilt too seldom sometimes (less than once a month)
    # Common useful utilities
    software-properties-common \
    python3-setuptools \
    python3-apt \
    python3-pip \
    python3-venv \
    python3.10-venv \
    python3-pytest \
    libpython3.10-dev \
    python-is-python3 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

###
# ensure image runs as unpriveleged user by default.
###
USER ${CODE_USER}

```
