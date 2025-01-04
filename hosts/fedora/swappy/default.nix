{ config, lib, ... }:

{
  options.pkgconfig.swappy = {
    enable = lib.mkEnableOption "Enable swappy configuration.";
  };

  config.xdg.configFile."swappy/config".text = lib.mkIf config.pkgconfig.swappy.enable ''
    [Default]
    save_dir = $HOME/Pictures/Screenshots/grim
  '';
}
