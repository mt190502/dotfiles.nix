{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.darwin.fontconfig;
in
{
  config = lib.mkIf cfg.enable {
    fonts.packages = with pkgs; [
      cantarell-fonts
      cascadia-code
      dejavu_fonts
      fira-code
      hack-font
      jetbrains-mono
      meslo-lgs-nf
      nerd-fonts.droid-sans-mono
      nerd-fonts.iosevka
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      noto-fonts
    ];
  };
}
