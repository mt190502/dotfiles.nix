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
    "build-setup" = "meson setup build";
    "build-run" = "ninja -C build && ./build/${projectName}";
    "build-debug" = "gdb --args ./build/${projectName}";
    "build-test" = "meson test -C build --print-errorlogs";
    "build-clean" = "ninja -C build clean";
  };

  #~ Environment Variables
  environmentVars = {
    CC = "clang";
    CXX = "clang++";
    CMAKE_EXPORT_COMPILE_COMMANDS = "1";
  };

  #~ Packages
  commonPackages = with pkgs; [
    #~ LLVM Toolchain
    llvmPackages.clang-tools
    llvmPackages.clang
    llvm

    #~ Build System
    meson
    ninja

    #~ Debug Tools
    gdb
    gef

    #~ Development Tools
    direnv
    pkg-config

    #~ Required Libraries
    # libyamlcpp
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
    echo "================================================================="
    echo "🚀 ${projectName} Development Environment (C++ Compiler Version $($CXX --version | head -n1))"
    echo "================================================================="
    if [ ! -f .envrc ]; then
      echo "use flake" > .envrc
      echo "📝 Created .envrc for direnv integration"
      echo "Please run 'direnv allow' to enable it."
      echo "================================================================="
    fi
    echo "To build and run the project, use the 'build-setup && build-run' commands."
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
