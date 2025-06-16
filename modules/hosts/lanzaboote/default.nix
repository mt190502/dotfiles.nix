{ lib, ... }:

{
  options.moduleopts.nixos.lanzaboote = {
    enable = lib.mkEnableOption "lanzaboote";
  };
}
