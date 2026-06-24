{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gimp
    inkscape
    krita
    kdePackages.kdenlive
  ];
}
