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
  users.users.taha = {
    shell = pkgs.fish;
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets."taha/shadow".path;
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
        syncthing
        vicinae
        yazi
        ytdlp
        zed
      ])
      ++ (with inputs.self.homeProfiles; [
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
