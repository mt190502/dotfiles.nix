{
  config,
  inputs,
  lib,
  ...
}:

let
  keys = import ../users/keys.nix;
  inherit (config) sharing;
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
    lib.filterAttrs (_: cfg: cfg.platform == platform) hostConfigs;

  defaultHomeModules = [
    "bin"
    "ssh"
    "preferences"
    "scripts"
    "sops"
    "wrapped"
  ];

  defaultNixosModules = [
    "resolved"
    "sops"
    "tailscale"
  ];

  defaultNixosProfiles = [
    "base"
  ];

  buildRPIConfig =
    name: cfg:
    let
      pkgs = repo "nixpkgs" cfg.arch;
      pkgs-unstable = repo "nixpkgs-unstable" cfg.arch;
      userConfigs = map (u: lib.attrByPath [ u "nixos" ] { } sharing.users) cfg.users;
      userKeyConfigs = map (u: {
        users.users.${u}.openssh.authorizedKeys.keys = keys.all or [ ];
      }) cfg.users;
      profileConfigs = map (p: sharing.profiles.nixos.${p} or { }) (
        (cfg.profiles or [ ]) ++ defaultNixosProfiles
      );
      moduleConfigs = map (m: inputs.self.nixosModules.${m} or { }) (
        (cfg.modules or [ ]) ++ defaultNixosModules
      );
      homeModules = map (m: inputs.self.homeModules.${m} or { }) defaultHomeModules;
      hostConfig = {
        nix.settings = cfg.nixSettings or { };
        system.stateVersion = cfg.stateVersion;
        users.mutableUsers = false;
      };
    in
    inputs.nixos-raspberrypi.lib.nixosSystem {
      inherit pkgs;
      specialArgs = {
        inherit inputs pkgs-unstable sharing;
        flakeName = name;
        system = cfg.arch;
      };
      modules = [
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.sharedModules = homeModules;
        }
        ./${name}
      ]
      ++ moduleConfigs
      ++ profileConfigs
      ++ userConfigs
      ++ userKeyConfigs
      ++ [
        hostConfig
        cfg.extraConfig
      ];
    };

  buildNixosConfig =
    name: cfg:
    let
      pkgs = repo "nixpkgs" cfg.arch;
      pkgs-unstable = repo "nixpkgs-unstable" cfg.arch;
      userConfigs = map (u: lib.attrByPath [ u "nixos" ] { } sharing.users) cfg.users;
      userKeyConfigs = map (u: {
        users.users.${u}.openssh.authorizedKeys.keys = keys.all or [ ];
      }) cfg.users;
      profileConfigs = map (p: sharing.profiles.nixos.${p} or { }) (
        (cfg.profiles or [ ]) ++ defaultNixosProfiles
      );
      moduleConfigs = map (m: inputs.self.nixosModules.${m} or { }) (
        (cfg.modules or [ ]) ++ defaultNixosModules
      );
      homeModules = map (m: inputs.self.homeModules.${m} or { }) defaultHomeModules;
      hostConfig = {
        nix.settings = cfg.nixSettings or { };
        system.stateVersion = cfg.stateVersion;
        users.mutableUsers = false;
      };
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit pkgs;
      specialArgs = {
        inherit inputs pkgs-unstable sharing;
        flakeName = name;
        system = cfg.arch;
      };
      modules = [
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.sharedModules = homeModules;
        }
        ./${name}
      ]
      ++ moduleConfigs
      ++ profileConfigs
      ++ userConfigs
      ++ userKeyConfigs
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
      userConfigs = map (u: lib.attrByPath [ u "darwin" ] { } sharing.users) cfg.users;
      userKeyConfigs = map (u: {
        users.users.${u}.openssh.authorizedKeys.keys = keys.all or [ ];
      }) cfg.users;
      profileConfigs = map (p: sharing.profiles.darwin.${p} or { }) cfg.profiles;
      moduleConfigs = map (m: inputs.self.darwinModules.${m} or { }) cfg.modules;
      homeModules = map (m: inputs.self.homeModules.${m} or { }) defaultHomeModules;
      hostConfig = {
        nix.settings = cfg.nixSettings or { };
        system.primaryUser = cfg.primaryUser;
        system.stateVersion = cfg.stateVersion;
      };
    in
    inputs.nix-darwin.lib.darwinSystem {
      inherit pkgs;
      specialArgs = {
        inherit inputs pkgs-unstable sharing;
        flakeName = name;
        system = cfg.arch;
      };
      modules = [
        inputs.home-manager.darwinModules.default
        {
          home-manager.sharedModules = homeModules;
        }
        ./${name}
      ]
      ++ moduleConfigs
      ++ profileConfigs
      ++ userConfigs
      ++ userKeyConfigs
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
      userConfig = lib.attrByPath [ cfg.user "home" ] { } sharing.users;
      profileConfigs = map (p: sharing.profiles.home.${p} or { }) cfg.profiles;
      moduleConfigs = map (m: inputs.self.homeModules.${m} or { }) (cfg.modules ++ defaultHomeModules);
      hostConfig = {
        home.stateVersion = cfg.stateVersion;
      };
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit inputs pkgs-unstable sharing;
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
    nixosConfigurations =
      (builtins.mapAttrs buildNixosConfig (getConfigsByPlatform "nixos"))
      // (builtins.mapAttrs buildRPIConfig (getConfigsByPlatform "rpi"));
    darwinConfigurations = builtins.mapAttrs buildDarwinConfig (getConfigsByPlatform "darwin");
    homeConfigurations = builtins.mapAttrs buildHomeConfig (getConfigsByPlatform "home");
  };
}
