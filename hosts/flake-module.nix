{ inputs, ... }:

let 
  nixpkgs_opts = { config.allowUnfree = true; };
in
{
  flake.homeConfigurations = {
    msi-h510m-pro-fedora = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux" // nixpkgs_opts;
      extraSpecialArgs = {
        inherit inputs;
        pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages."x86_64-linux" // nixpkgs_opts;
      };
      modules = [
        ./msi-h510m-pro-fedora/home
        (inputs.self + "/users/taha/home")
      ];
    };
    lenovo-thinkpad-e14-fedora = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux" // nixpkgs_opts;
      extraSpecialArgs = {
        inherit inputs;
        pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages."x86_64-linux" // nixpkgs_opts;
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
      specialArgs = {
        inherit inputs;
        pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages."${system}" // nixpkgs_opts;
      };
      modules = [
        ./lenovo-thinkpad-e14-nixos
        (inputs.self + "/users/taha")
        inputs.home-manager.nixosModules.home-manager
      ];
    };
    msi-h510m-pro-nixos = inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages."${system}" // nixpkgs_opts;
      };
      modules = [
        ./msi-h510m-pro-nixos
        (inputs.self + "/users/taha")
        inputs.home-manager.nixosModules.home-manager
      ];
    };
  };
}
