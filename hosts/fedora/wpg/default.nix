{ lib, ... }:

{
  options.pkgconfig.wpg = {
    enable = lib.mkEnableOption "Enable wpg configuration.";
  };
}
