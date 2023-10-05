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

## Custom Software

Custom software, such as [rust], [python], or [node] is expected to be installed with [nix] [flakes], which are both installed in the [Dockerfile](./Dockerfile).

This image allows [direnv] to be setup to use [nix] [flakes] to install software on the loading of your code directory.

Examples of this can be found in the [dev-templates] repository.

This image is used primarily to have the same packaging workflow on Windows as we do on MacOS or Linux operating systems.
As we prefer to keep our operating systems clean, the project repository that uses this devcontainer should declaritively show all needed dependencies in their `flake.nix` file.

One could make separate images for each language, but I prefer to have one image for all my development needs as the size of this alpine based image is small enough for my needs.

## Custom Preferences

I installed ohmyzsh, along with powerlevel10k in the [Dockerfile](./Dockerfile).

For powerlevel10k, the [fonts](https://github.com/romkatv/powerlevel10k#manual-font-installation) needs to be installed on the host/client machine, not inside the container.

## .devcontainer/devcontainer.json

As is, with no configuration

```json
{
  "image": "ghcr.io/iancleary/devcontainer:tag",
  "remoteUser": "root"
}
```

With a Dockerfile in the `.devcontainer` folder

```json
{
  "build": {
    "dockerfile": "Dockerfile"
  },
  "remoteUser": "root"
}
```

With a Dockerfile in the root of the project

```json
{
  "build": {
    "dockerfile": "../Dockerfile"
  },
  "remoteUser": "root"
}
```

Recommended way to install packages with [nix] [flakes] and [direnv] in the `flake.nix` and `.envrc` files within your repo, not the Dockerfile:

`.envrc`

```bash
use flake .

```

`flake.nix` example from [dev-templates]'s python directory

```nix
{
  description = "A Nix-flake-based Python development environment";

  # GitHub URLs for the Nix inputs we're using
  inputs = {
    # Simply the greatest package repository on the planet
    nixpkgs.url = "github:NixOS/nixpkgs";
    # A set of helper functions for using flakes
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, mach-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # task runner
        just = pkgs.just;

        # Python 3.11
        python = pkgs.python311;

        # Run python packages in a isolated environment
        pipx = pkgs.python311Packages.pipx;

        # Python tools, as a list
        pythonTools = [ python pipx];
      in {
        devShells = {
          default = pkgs.mkShell {
            # Packages included in the environment
            buildInputs = [ just ] ++ pythonTools;

            # Run when the shell is started up
            shellHook = ''
              ${python}/bin/python --version
              ${python}/bin/python -m venv .venv
              source .venv/bin/activate
              export PIPX_HOME=.venv/pipx
              export PIPX_BIN_DIR=.venv/bin
              echo "pipx $(pipx --version)"
              pipx install pdm
              pipx install pre-commit
              pdm --version
              pdm install
              pre-commit --version
              pre-commit install
            '';

            # https://pypa.github.io/pipx/docs/
            # optional environment variables:
            #   PIPX_HOME             Overrides default pipx location. Virtual Environments
            #                         will be installed to $PIPX_HOME/venvs.
            #   PIPX_BIN_DIR          Overrides location of app installations. Apps are
            #                         symlinked or copied here.
            #
          };
        };
      });
}
```

Dockerfile contents, if customizing the dockerfile (not recommended):

```Dockerfile
FROM ghcr.io/iancleary/devcontainer:tag

USER root

# install alpine packages with apk
RUN apk add --no-cache \
    # ========================================================
    # ======= I'm using `tzdata` as an example =================
    # ========================================================
    tzdata

# Search for packages here
# https://pkgs.alpinelinux.org/packages?name=&branch=v3.18

###
# ensure image runs as unprivileged user by default.
###
USER ${CODE_USER}
```

[dev-templates]: https://github.com/iancleary/dev-templates
[flakes]: https://nixos.wiki/wiki/Flakes
[nix]: https://nixos.org
[node]: https://nodejs.org
[proto]: https://developers.google.com/protocol-buffers
[python]: https://python.org
[rust]: https://rust-lang.org
