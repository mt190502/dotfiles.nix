{
  config,
  inputs,
  flakeName,
  system,
  pkgs,
  pkgs-unstable,
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
        inputs
        flakeName
        system
        pkgs-unstable
        ;
    };
    users.rose = {
      nixpkgs.config.allowUnfree = true;
      imports = [
        ./default.nix
      ]
      ++ (with inputs.self.homeModules; [
        bin
        fastfetch
        fish
        fontconfig
        git
        gtk
        kdeconnect
        mangohud
        mpv
        preferences
        rnnoise
        sops
        stylix
        syncthing
        wrapped
        ytdlp
      ])
      ++ (with inputs.self.homeProfiles; [
        plasma
      ]);
    };
  };
}
