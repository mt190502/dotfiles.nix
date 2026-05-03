{ lib, inputs, ... }:

let
  repo =
    name: arch:
    import inputs.${name} {
      system = arch;
      config.allowUnfree = true;
    };

  getConfigsByPlatform =
    platform:
    let
      entries = builtins.readDir ./.;
      dirs = lib.filterAttrs (
        name: type: type == "directory" && builtins.pathExists ./${name}/config.nix
      ) entries;
      hostConfigs = lib.mapAttrs (name: _: import ./${name}/config.nix) dirs;
    in
    lib.filterAttrs (name: cfg: cfg.platform == platform) hostConfigs;

  buildNixosConfig =
    name: cfg:
    let
      pkgs = repo "nixpkgs" cfg.arch;
      pkgs-unstable = repo "nixpkgs-unstable" cfg.arch;
      userConfigs = map (u: lib.attrByPath [ u "nixos" ] { } (inputs.self.users or { })) cfg.users;
      profileConfigs = map (p: inputs.self.nixosProfiles.${p} or { }) cfg.profiles;
      moduleConfigs = map (m: inputs.self.nixosModules.${m} or { }) cfg.modules;
      hostConfig = {
        system.stateVersion = cfg.stateVersion;
        nix.settings = cfg.nixSettings or { };
      };
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit pkgs;
      specialArgs = {
        inherit inputs pkgs-unstable;
        flakeName = name;
        system = cfg.arch;
      };
      modules = [
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.home-manager
        ./${name}
      ]
      ++ moduleConfigs
      ++ profileConfigs
      ++ userConfigs
      ++ [
        hostConfig
        cfg.extraConfig
      ];
    };

  buildDarwinConfig =
    name: cfg:
    let
      pkgs = repo "nixpkgs" cfg.arch;
      pkgs-unstable = repo "nixpkgs-unstable" cfg.arch;
      userConfigs = map (u: lib.attrByPath [ u "darwin" ] { } (inputs.self.users or { })) cfg.users;
      profileConfigs = map (p: inputs.self.nixosProfiles.${p} or { }) cfg.profiles;
      moduleConfigs = map (m: inputs.self.darwinModules.${m} or { }) cfg.modules;
      hostConfig = {
        system.primaryUser = cfg.primaryUser;
        system.stateVersion = cfg.stateVersion;
        nix.settings = cfg.nixSettings or { };
      };
    in
    inputs.nix-darwin.lib.darwinSystem {
      inherit pkgs;
      specialArgs = {
        inherit inputs pkgs-unstable;
        flakeName = name;
        system = cfg.arch;
      };
      modules = [
        inputs.home-manager.darwinModules.default
        ./${name}
      ]
      ++ moduleConfigs
      ++ profileConfigs
      ++ userConfigs
      ++ [
        hostConfig
        cfg.extraConfig
      ];
    };

  buildHomeConfig =
    name: cfg:
    let
      pkgs = repo "nixpkgs" cfg.arch;
      pkgs-unstable = repo "nixpkgs-unstable" cfg.arch;
      userConfig = lib.attrByPath [ cfg.user "home" ] { } (inputs.self.users or { });
      profileConfigs = map (p: inputs.self.homeProfiles.${p} or { }) cfg.profiles;
      moduleConfigs = map (m: inputs.self.homeModules.${m} or { }) (
        cfg.modules
        ++ [
          "bin"
          "preferences"
          "sops"
          "stylix"
          "wrapped"
        ]
      );
      hostConfig = {
        home.stateVersion = cfg.stateVersion;
      };
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit inputs;
        inherit pkgs-unstable;
        flakeName = name;
        system = cfg.arch;
      };
      modules =
        moduleConfigs
        ++ profileConfigs
        ++ [
          ./${name}
          userConfig
          hostConfig
          cfg.extraConfig
        ];
    };
in
{
  flake = {
    nixosConfigurations = builtins.mapAttrs buildNixosConfig (getConfigsByPlatform "nixos");
    darwinConfigurations = builtins.mapAttrs buildDarwinConfig (getConfigsByPlatform "darwin");
    homeConfigurations = builtins.mapAttrs buildHomeConfig (getConfigsByPlatform "home");
  };
}
