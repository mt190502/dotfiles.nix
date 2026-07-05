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
  users.users.droid = {
    shell = pkgs.fish;
    hashedPasswordFile = config.sops.secrets."droid/shadow".path;
    isNormalUser = true;
    extraGroups = [
      "audio"
      "droid"
      "render"
      "seat"
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
    users.droid = {
      nixpkgs.config.allowUnfree = true;
      imports = [
        ./default.nix
      ]
      ++ (with inputs.self.homeModules; [
        cnf
        delta
        fastfetch
        fish
        git
        ssh
      ])
      ++ (with sharing.profiles.home; [
        neovim
        tmux
      ]);
    };
  };
}
