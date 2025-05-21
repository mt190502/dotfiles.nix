{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    flatpak
    gparted
    gtklock
    librewolf
    lm_sensors
    psmisc
    solaar
    v4l-utils
    vim
    xdg-utils
  ];
  networking.hostName = "190502";
  programs.dconf.enable = true;
  services = {
    blueman.enable = true;
    gnome.gnome-keyring.enable = true;
    logrotate.checkConfig = false;
    pipewire = {
      enable = true;
      pulse.enable = true;
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
