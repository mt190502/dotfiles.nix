{ inputs, pkgs, ... }:

{
  environment.systemPackages =
    with pkgs;
    [
      android-tools
      ethtool
      gnome-text-editor
      gparted
      libreoffice
      libva-utils
      loupe
      seahorse
      snapshot
      v4l-utils
      xdg-user-dirs
      xdg-user-dirs-gtk
      xdg-utils
    ]
    ++ (with inputs.self.packages.${pkgs.stdenv.hostPlatform.system}; [
      openboard
    ]);
  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        openssl
        zlib
        glibc
      ];
    };
    dconf.enable = true;
  };
  services = {
    blueman.enable = true;
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    logrotate.checkConfig = false;
    openssh.enable = true;
    smartd.enable = true;
    upower.enable = true;
    zram-generator = {
      enable = true;
      settings = {
        zram0 = {
          compression-algorithm = "zstd";
          zram-size = "ram";
        };
      };
    };
  };
}
