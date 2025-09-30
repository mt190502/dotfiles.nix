{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    btrfs-assistant
    flat-remix-icon-theme
    flatpak
    gparted
    gtklock
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
  xdg = {
    autostart.enable = true;
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      config.common.default = "*";
    };
  };
}
