{ lib, ... }:

{
  options.moduleopts.nixos.kdeconnect = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "kdeconnect";
    };
  };
}
