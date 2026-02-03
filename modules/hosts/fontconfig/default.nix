{ lib, ... }:

let
  opt = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to enable fontconfig.";
  };
in
{
  options.moduleopts = {
    nixos.fontconfig.enable = opt;
    darwin.fontconfig.enable = opt;
  };
}
