{ pkgs, inputs, ... }:

{
  fonts = {
    packages = with pkgs; [
      corefonts
      eb-garamond
      inputs.self.packages.${stdenv.hostPlatform.system}.msfonts
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
