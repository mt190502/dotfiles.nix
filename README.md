# mt190502's dots

This dots is created for my personal use. I using with Nix Package Manager, so you can use it with NixOS or Nix installed on your system.

## Installation

- First, set up some packages on your system (I'm using Fedora, so you can use this command to install them)

    ```sh
    sudo dnf install -y git curl swaylock
    ```

  - I installed swaylock on Fedora because home-manager doesn't compatible with pam-locking. If you're using another distro, you can install it with your package manager.

- Set up Nix Package Manager on your system (if you haven't already or you don't have NixOS installed)

    ```sh
    NIX_VERSION="24.11"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    sudo -i nix-channel --add https://nixos.org/channels/nixpkgs-${NIX_VERSION} nixpkgs
    nix-channel --add https://nixos.org/channels/nixpkgs-${NIX_VERSION} nixpkgs
    nix-channel --update
    ```

- Enable flake support in Nix

    ```sh
    echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
    ```

- Set up home-manager from [this](https://nix-community.github.io/home-manager/index.xhtml#ch-installation) source

- Clone this repository

    ```sh
    git clone git@github.com:mt190502/dotfiles.nix
    cd dotfiles.nix
    ```

- Switch this flake

    ```sh
    home-manager build --no-out-link --flake .#fedora
    home-manager switch --no-out-link --flake .#fedora
    ```

- Enjoy!

## Screenshot

![image](https://github.com/user-attachments/assets/07a3f209-b253-475a-a681-2f6c03eaa512)
