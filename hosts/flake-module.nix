{ inputs, ... }:

let
  darwinConfigs = [
    {
      name = "macbook-m3-air-work";
      arch = "aarch64-darwin";
    }
  ];
  homeConfigs = [
    {
      name = "msi-h510m-pro-fedora";
      arch = "x86_64-linux";
    }
  ];
  nixosConfigs = [
    {
      name = "lenovo-thinkpad-e14-nixos";
      arch = "x86_64-linux";
    }
    {
      name = "msi-h510m-pro-nixos";
      arch = "x86_64-linux";
    }
  ];
  repo =
    name: arch:
    (import inputs.${name} {
      system = arch;
      config.allowUnfree = true;
    });
in
{
  flake = {
    darwinConfigurations = builtins.listToAttrs (
      map (cfg: {
        inherit (cfg) name;
        value = inputs.nix-darwin.lib.darwinSystem rec {
          system = cfg.arch;
          pkgs = repo "nixpkgs" system;
          specialArgs = {
            inherit inputs system;
            pkgs-unstable = repo "nixpkgs-unstable" system;
            flakeName = cfg.name;
          };
          modules = [
            inputs.home-manager.darwinModules.default
            (inputs.self + "/users/taha")
            ./${cfg.name}
          ];
        };
      }) darwinConfigs
    );
    homeConfigurations = builtins.listToAttrs (
      map (cfg: {
        inherit (cfg) name;
        value = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = repo "nixpkgs" cfg.arch;
          extraSpecialArgs = {
            inherit inputs;
            pkgs-unstable = repo "nixpkgs-unstable" cfg.arch;
            flakeName = cfg.name;
            system = cfg.arch;
          };
          modules = [
            (inputs.self + "/users/taha/linux.nix")
            ./${cfg.name}/home
          ];
        };
      }) homeConfigs
    );
    nixosConfigurations = builtins.listToAttrs (
      map (cfg: {
        inherit (cfg) name;
        value = inputs.nixpkgs.lib.nixosSystem rec {
          system = cfg.arch;
          pkgs = repo "nixpkgs" system;
          specialArgs = {
            inherit inputs system;
            pkgs-unstable = repo "nixpkgs-unstable" system;
            flakeName = cfg.name;
          };
          modules = [
            inputs.home-manager.nixosModules.home-manager
            (inputs.self + "/users/taha")
            ./${cfg.name}
          ];
        };
      }) nixosConfigs
    );
  };
}
