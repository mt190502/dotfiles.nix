{
  description = "M.Taha's Ultimate Nix Configuration Flake v2.0";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-26.05";
    };
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-avf = {
      url = "github:yvt/nixos-avf/android-17";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    ihtc = {
      url = "git+https://src.krea.to/kreato/ihtc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.pre-commit-hooks.flakeModule
        ./hosts/flake-module.nix
        ./modules/flake-module.nix
        ./packages/flake-module.nix
        ./profiles/flake-module.nix
        ./secrets/flake-module.nix
        ./users/flake-module.nix
      ];
      perSystem =
        {
          lib,
          pkgs,
          config,
          ...
        }:
        {
          pre-commit.settings.hooks = {
            nixfmt.enable = true;
            nil.enable = true;
            deadnix.enable = true;
            statix.enable = true;
            check-sops = {
              enable = true;
              name = "check-sops";
              description = "Check that all secret files are encrypted with SOPS";
              files = "secret";
              excludes = [
                "\\.example$"
                "\\.nix$"
              ];
              entry = "${pkgs.writeShellScript "check-sops" ''
                for f in "$@"; do
                  if ! out=$(${lib.getExe pkgs.sops} filestatus "$f" 2>&1); then
                    echo "File $f is not encrypted with SOPS (or sops failed: $out)"
                    exit 1
                  fi
                  if ! echo "$out" | grep -q '"encrypted":true'; then
                    echo "File $f is not encrypted with SOPS"
                    exit 1
                  fi
                done
              ''}";
              pass_filenames = true;
            };
          };
          devShells.default = pkgs.mkShell {
            shellHook = config.pre-commit.settings.shellHook;
            buildInputs = config.pre-commit.settings.enabledPackages;
          };
        };
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
    };
}
