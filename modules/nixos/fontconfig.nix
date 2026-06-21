{ pkgs, inputs, ... }:

{
  fonts = {
    packages =
      with pkgs;
      with inputs.self.packages.${stdenv.hostPlatform.system};
      with inputs.apple-fonts.packages.${stdenv.hostPlatform.system};
      [
        corefonts
        eb-garamond
        msfonts
        sf-pro-nerd
        sf-mono
        vista-fonts
        vista-fonts-chs
        vista-fonts-cht
      ];
    fontconfig = {
      enable = true;
      antialias = true;
      cache32Bit = true;
      hinting = {
        enable = true;
        autohint = true;
        style = "slight";
      };
      includeUserConf = true;
      subpixel = {
        lcdfilter = "default";
        rgba = "rgb";
      };
      useEmbeddedBitmaps = true;
    };
  };
}
