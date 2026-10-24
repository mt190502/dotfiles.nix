{
  lib ? import <nixpkgs/lib>,
  pkgs ? import <nixpkgs> { },
  ...
}:

let
  #~ Project Configuration
  projectName = "MyProject";

  #~ Aliases for development shell
  aliases = {
    "build-setup" = "go mod tidy";
    "build-build" = "go build -o ./.tmp/main ./cmd/app";
    "build-run" = "go run ./cmd/app";
    "build-debug" = "dlv debug --headless --listen=:2345 --api-version=2";
    "build-test" = "go test ./... -v";
    "build-clean" = "go clean -cache -testcache -modcache";
  };

  #~ Environment Variables
  environmentVars = {
    # GOARCH = "amd64";
    # GOOS = "linux";
  };

  commonPackages = with pkgs; [
    #~ Go Toolchain
    go

    #~ Build System
    air

    #~ Debug Tools
    delve

    #~ Development Tools
    direnv
  ];

  shells = rec {
    default = zsh;
    bash = {
      packages = [ ];
      environments = { };
      hooks = ''
        # Setup temporary bash configuration
        export HISTFILE="$PWD/.bash_history"

        # Generate runtime bashrc
        echo -e 'export PS1="\[\e[32m\]\u@\h:\[\e[34m\]\w\[\e[0m\]$ "
        ' > $PWD/.bashrc
      '';
    };
    zsh = {
      packages = with pkgs; [
        oh-my-zsh
        zsh-completions
        zsh-autosuggestions
        zsh-syntax-highlighting
      ];
      environments = {
        ZSH_THEME = "amuse";
        ZSH_COMPDUMP = "/tmp/.zcompdump";
      };
      hooks = ''
        # Setup temporary zsh configuration
        export ZDOTDIR=$PWD
        export HISTFILE="$PWD/.zsh_history"

        # Generate runtime zshrc
        echo -e 'export ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh"

        # Completions
        fpath=(${pkgs.zsh-completions}/share/zsh/site-functions $fpath)
        autoload -U compinit && compinit

        # Autosuggestions
        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

        # Syntax highlighting
        source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

        # Set plugins
        plugins=(git colored-man-pages command-not-found)
        source $ZSH/oh-my-zsh.sh

        # Aliases and Functions
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: cmd: "alias ${name}=\"${cmd}\"") aliases)}
        ' > $ZDOTDIR/.zshrc
        if [ -t 1 ] && [ -z "$VSCODE_CLI" ]; then
          exec ${pkgs.zsh}/bin/zsh
        fi
      '';
    };
  };

  commonHooks = ''
    export GOPATH="$PWD/.gopath"
    export GOBIN="$GOPATH/bin"
    mkdir -p "$GOBIN"
    echo "================================================================="
    echo "🚀 ${projectName} Development Environment (Go Version: $(go version | awk '{print $3}' | sed 's/go//g'))"
    echo "================================================================="
    if [ ! -f .envrc ]; then
      echo "use flake" > .envrc
      echo "📝 Created .envrc for direnv integration"
      echo "Please run 'direnv allow' to enable it."
      echo "================================================================="
    fi
    echo "To build the project, run 'build-setup' if not done already."
    echo "To run the project, use 'build-run' alias"
    echo "================================================================="
  '';
in
lib.mapAttrs (
  name: shell:
  pkgs.mkShellNoCC {
    buildInputs = commonPackages ++ shell.packages;
    shellHook = commonHooks + shell.hooks;
    env = shell.environments // environmentVars;
  }
) shells
