{
  config,
  flakeName,
  inputs,
  lib,
  pkgs,
  pkgs-unstable,
  sharing,
  system,
  ...
}:

{
  programs.fish.enable = true;
  users.users.srvadmin = {
    shell = pkgs.fish;
    hashedPasswordFile = config.sops.secrets."srvadmin/shadow".path;
    isNormalUser = true;
    extraGroups = [
      "audio"
      "video"
      "wheel"
    ]
    ++ lib.optionals config.networking.networkmanager.enable [
      "networkmanager"
    ];
  };
  home-manager = {
    useGlobalPkgs = false;
    extraSpecialArgs = {
      inherit
        flakeName
        inputs
        pkgs-unstable
        sharing
        system
        ;
    };
    users.srvadmin = {
      nixpkgs.config.allowUnfree = true;
      imports = [
        ./default.nix
      ]
      ++ (with inputs.self.homeModules; [
        fastfetch
        fish
      ])
      ++ (with sharing.profiles.home; [
      ]);
    };
  };
}
