{
  description = "M.Taha's Nix Configuration";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.11";
      flake = true;
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alacritty-theme = {
      url = "github:alexghr/alacritty-theme.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.5.2";
    stylix = {
      url = "github:danth/stylix/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nix-flatpak,
      stylix,
      ...
    }:
    {
      # packages."x86_64-linux" = nixpkgs.lib.mapAttrs' (n: v: {
      #   name = (nixpkgs.lib.removeSuffix ".nix" n);
      #   value = v;
      # }) (nixpkgs.lib.genAttrs
      #   (nixpkgs.lib.attrNames (builtins.readDir ./packages)) (p:
      #     nixpkgs.legacyPackages."x86_64-linux".callPackage ./packages/${p} { }));
      homeConfigurations."fedora" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = { inherit inputs; };
        modules = [
          stylix.homeManagerModules.stylix
          nix-flatpak.homeManagerModules.nix-flatpak
          ./hosts/fedora/home.nix
        ];
      };
    };
}
