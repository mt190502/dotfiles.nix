{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ayatana-ido
    btrfs-assistant
    flat-remix-icon-theme
    flatpak
    gparted
    gtklock
    libayatana-appindicator
    libayatana-appindicator-gtk3
    libayatana-common
    libayatana-indicator
    libayatana-indicator-gtk3
    librewolf
    libva-utils
    lm_sensors
    psmisc
    v4l-utils
    vim
    xdg-user-dirs
    xdg-user-dirs-gtk
    xdg-utils
  ];
  programs.dconf.enable = true;
  programs.system-config-printer.enable = true;
  services = {
    blueman.enable = true;
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    logrotate.checkConfig = false;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      wireplumber.enable = true;
    };
    printing = {
      enable = true;
      drivers = with pkgs; [ canon-cups-ufr2 ];
      browsed.enable = true;
    };
    smartd.enable = true;
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
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
    config.common.default = "*";
  };
}
