{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    flat-remix-gnome
    flat-remix-gtk
    flat-remix-icon-theme
    gnome-text-editor
    gparted
    librewolf
    libva-utils
    loupe
    lm_sensors
    openboard
    psmisc
    seahorse
    v4l-utils
    vim
    xdg-user-dirs
    xdg-user-dirs-gtk
    xdg-utils
  ];
  programs = {
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
