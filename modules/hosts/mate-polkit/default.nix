{ lib, ... }:

{
  options.moduleopts.nixos.mate-polkit = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "mate-polkit";
    };
  };
}
