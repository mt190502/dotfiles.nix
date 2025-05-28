{ lib, ... }:

{
  options.moduleopts.nixos.printing = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "printing";
    };
  };
}
