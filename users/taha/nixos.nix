{
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
        bin
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
        kde-apps-wm-fix
        kdeconnect
        mangohud
        mpdris2-rs
        mpv
        preferences
        qt-apps-wm-fix
        rmpc
        rnnoise
        scripts
        stylix
        swappy
        syncthing
        vicinae
        wrapped
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
