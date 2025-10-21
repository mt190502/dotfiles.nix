{ inputs, ... }:

let
  homeConfigs = [
    {
      name = "lenovo-thinkpad-e14-fedora";
      arch = "x86_64-linux";
    }
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
  flake.homeConfigurations = builtins.listToAttrs (
    map (cfg: {
      name = cfg.name;
      value = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = repo "nixpkgs" cfg.arch;
        extraSpecialArgs = {
          inherit inputs;
          pkgs-unstable = repo "nixpkgs-unstable" cfg.arch;
          flakeName = cfg.name;
        };
        modules = [
          (inputs.self + "/users/taha/home")
          ./${cfg.name}/home
        ];
      };
    }) homeConfigs
  );
  flake.nixosConfigurations = builtins.listToAttrs (
    map (cfg: {
      name = cfg.name;
      value = inputs.nixpkgs.lib.nixosSystem rec {
        system = cfg.arch;
        pkgs = repo "nixpkgs" system;
        specialArgs = {
          inherit inputs;
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
}
