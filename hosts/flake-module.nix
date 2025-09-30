{ inputs, ... }:

let
  homeConfigs = [
    "lenovo-thinkpad-e14-fedora"
    "msi-h510m-pro-fedora"
  ];
  nixosConfigs = [
    "lenovo-thinkpad-e14-nixos"
    "msi-h510m-pro-nixos"
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
    map (name: {
      name = name;
      value = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = repo "nixpkgs" "x86_64-linux";
        extraSpecialArgs = {
          inherit inputs;
          pkgs-unstable = repo "nixpkgs-unstable" "x86_64-linux";
          flakeName = name;
        };
        modules = [
          ./${name}/home
          (inputs.self + "/users/taha/home")
        ];
      };
    }) homeConfigs
  );
  flake.nixosConfigurations = builtins.listToAttrs (
    map (name: {
      name = name;
      value = inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        pkgs = repo "nixpkgs" system;
        specialArgs = {
          inherit inputs;
          pkgs-unstable = repo "nixpkgs-unstable" system;
          flakeName = name;
        };
        modules = [
          ./${name}
          (inputs.self + "/users/taha")
          inputs.home-manager.nixosModules.home-manager
        ];
      };
    }) nixosConfigs
  );
}
