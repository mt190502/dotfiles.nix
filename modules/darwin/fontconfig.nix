{ pkgs, inputs, ... }:

{
  fonts.packages =
    with pkgs;
    with inputs.self.packages.${stdenv.hostPlatform.system};
    [
      cantarell-fonts
      cascadia-code
      dejavu_fonts
      fira-code
      hack-font
      iosevka-nerd-font
      jetbrains-mono
      meslo-lgs-nf
      nerd-fonts.droid-sans-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];
}
