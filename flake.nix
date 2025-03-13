{
  description = "M.Taha's Nix Configuration";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
      flake = true;
    };
    alacritty-theme = {
      url = "github:alexghr/alacritty-theme.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nix-flatpak,
      nixvim,
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
          nix-flatpak.homeManagerModules.nix-flatpak
          nixvim.homeManagerModules.nixvim
          stylix.homeManagerModules.stylix
          ./hosts/fedora/home.nix
        ];
      };
    };
}
