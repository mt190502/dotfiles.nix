{ lib, ... }:

{
  options.moduleopts.nixos.tlp = {
    enable = lib.mkEnableOption "tlp";
  };
}
