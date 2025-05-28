{ lib, ... }:

{
  options.moduleopts.nixos.system-extra = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "system-extra";
    };
  };
}
