{ lib, ... }:

{
  options.moduleopts.nixos.fontconfig = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "fontconfig";
    };
  };
}
