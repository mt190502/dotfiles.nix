#!/bin/bash

#################################################
#
## Variables
#
#################################################
NIX_VERSION=24.11
PACKAGES='lxappearance mpv swaylock sway wdisplays'

#################################################
#
## Functions
#
#################################################
read -p "Do you want to install the required packages? [y/N] " -n 1 -r choice1
read -p "Do you want to install Nix package manager? [y/N] " -n 1 -r choice2

#~ This packages is using gpu and this packages doesn't work correctly with NixGL and PAM
#~ So, we need to install the packages manually in the system
installRequiredPackages() {
    case $(awk -F= '$1 == "ID" { print $2 }' /etc/os-release) in
    arch)
        sudo pacman -S "$PACKAGES"
        ;;
    debian)
        sudo apt install "$PACKAGES"
        ;;
    fedora)
        sudo dnf install "$PACKAGES"
        ;;
    *)
        echo "Unknown distro"
        exit 1
        ;;
    esac
}
if [[ $choice1 =~ ^[Yy]$ ]]; then
    installRequiredPackages
else
    echo "Aborted installation of required packages"
    exit 1
fi

#~ Install nix package manager
installNixPackageManager() {
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    sudo -i nix-channel --add https://nixos.org/channels/nixpkgs-${NIX_VERSION} nixpkgs
    nix-channel --add https://nixos.org/channels/nixpkgs-${NIX_VERSION} nixpkgs
    nix-channel --update
}
if [[ $choice1 =~ ^[Yy]$ ]] && [[ $choice2 =~ ^[Yy]$ ]]; then
    installNixPackageManager
else
    echo "Aborted installation of Nix package manager"
    exit 1
fi
