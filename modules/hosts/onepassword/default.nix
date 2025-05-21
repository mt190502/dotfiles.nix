{ lib, ... }:

{
  options.moduleopts.nixos.onepassword = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "onepassword";
    };
  };
}
