{ pkgs, ... }:

{
  programs.evolution = {
    enable = true;
    plugins = with pkgs; [ ];
  };
  services.gnome.evolution-data-server = {
    enable = true;
    plugins = with pkgs; [ ];
  };
}
