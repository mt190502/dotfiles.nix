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
  users.users.taha = {
    shell = pkgs.fish;
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets."taha/shadow".path;
    extraGroups = [
      "audio"
      "video"
      "wheel"
    ]
    ++ lib.optionals config.networking.networkmanager.enable [
      "networkmanager"
    ]
    ++ lib.optionals config.virtualisation.libvirtd.enable [
      "kvm"
      "libvirtd"
      "qemu"
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
    users.taha = {
      nixpkgs.config.allowUnfree = true;
      imports = [
        ./home.nix
        ./default.nix
      ]
      ++ (with inputs.self.homeModules; [
        delta
        direnv
        fastfetch
        fish
        flatpak
        fontconfig
        foot
        git
        gnome-keyring
        gtk
        kdeconnect
        mangohud
        mpdris2-rs
        mpv
        rmpc
        rnnoise
        stylix
        syncthing
        vicinae
        yazi
        ytdlp
        zed
      ])
      ++ (with sharing.profiles.home; [
        ai
        cloud
        development
        mediaplayer
        neovim
        sway
        tmux
      ]);
    };
  };
}
