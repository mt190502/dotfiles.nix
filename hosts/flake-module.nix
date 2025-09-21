{ inputs, ... }:

let
  repo =
    name: arch:
    (import inputs.${name} {
      system = arch;
      config.allowUnfree = true;
    });
in
{
  flake.homeConfigurations = {
    msi-h510m-pro-fedora = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = repo "nixpkgs" "x86_64-linux";
      extraSpecialArgs = {
        inherit inputs;
        pkgs-unstable = repo "nixpkgs-unstable" "x86_64-linux";
      };
      modules = [
        ./msi-h510m-pro-fedora/home
        (inputs.self + "/users/taha/home")
      ];
    };
    lenovo-thinkpad-e14-fedora = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = repo "nixpkgs" "x86_64-linux";
      extraSpecialArgs = {
        inherit inputs;
        pkgs-unstable = repo "nixpkgs-unstable" "x86_64-linux";
      };
      modules = [
        ./lenovo-thinkpad-e14-fedora/home
        (inputs.self + "/users/taha/home")
      ];
    };
  };
  flake.nixosConfigurations = {
    lenovo-thinkpad-e14-nixos = inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      pkgs = repo "nixpkgs" system;
      specialArgs = {
        pkgs-unstable = repo "nixpkgs-unstable" system;
        inherit inputs;
      };
      modules = [
        ./lenovo-thinkpad-e14-nixos
        (inputs.self + "/users/taha")
        inputs.home-manager.nixosModules.home-manager
      ];
    };
    msi-h510m-pro-nixos = inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      pkgs = repo "nixpkgs" system;
      specialArgs = {
        pkgs-unstable = repo "nixpkgs-unstable" system;
        inherit inputs;
      };
      modules = [
        ./msi-h510m-pro-nixos
        (inputs.self + "/users/taha")
        inputs.home-manager.nixosModules.home-manager
      ];
    };
  };
}
