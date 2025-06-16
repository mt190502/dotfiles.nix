{ inputs, ... }:

{
  flake.homeConfigurations = {
    msi-h510m-pro-fedora = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
      extraSpecialArgs = {
        inherit inputs;
      };
      modules = [
        ./msi-h510m-pro-fedora/home
        (inputs.self + "/users/taha/home")
      ];
    };
    msi-h510m-pro-arch = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
      extraSpecialArgs = {
        inherit inputs;
      };
      modules = [
        ./msi-h510m-pro-arch/home
        (inputs.self + "/users/taha/home")
      ];
    };
  };
  flake.nixosConfigurations = {
    lenovo-thinkpad-e14-nixos = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./lenovo-thinkpad-e14-nixos
        (inputs.self + "/users/taha")
        inputs.home-manager.nixosModules.home-manager
      ];
    };
    msi-h510m-pro-nixos = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./msi-h510m-pro-nixos
        (inputs.self + "/users/taha")
        inputs.home-manager.nixosModules.home-manager
      ];
    };
  };
}
