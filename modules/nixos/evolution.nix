{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome-online-accounts-gtk
  ];
  programs.evolution = {
    enable = true;
    plugins = with pkgs; [ ];
  };
  services.gnome = {
    evolution-data-server = {
      enable = true;
      plugins = with pkgs; [ ];
    };
    gnome-online-accounts.enable = true;
  };
}
