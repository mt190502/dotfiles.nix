{ pkgs, ... }:

{
  config.stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/apathy.yaml";
    image = ../../../../../assets/wallpaper3.jpg;
  };
}
