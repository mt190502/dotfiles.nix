{
  config,
  flakeName,
  inputs,
  pkgs,
  pkgs-unstable,
  sharing,
  system,
  ...
}:

{
  programs.fish.enable = true;
  users.users.rose = {
    shell = pkgs.fish;
    hashedPasswordFile = config.sops.secrets."rose/shadow".path;
    isNormalUser = true;
    extraGroups = [
      "audio"
      "kvm"
      "libvirtd"
      "networkmanager"
      "qemu"
      "video"
      "wheel"
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
    users.rose = {
      nixpkgs.config.allowUnfree = true;
      imports = [
        ./default.nix
      ]
      ++ (with inputs.self.homeModules; [
        fastfetch
        fish
        fontconfig
        git
        gtk
        kdeconnect
        mangohud
        mpv
        rnnoise
        syncthing
        ytdlp
      ])
      ++ (with sharing.profiles.home; [
        plasma
      ]);
    };
  };
}
