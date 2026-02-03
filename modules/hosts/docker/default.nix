{ lib, ... }:

let
  opt = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to enable docker.";
  };
in
{
  options.moduleopts = {
    nixos.docker.enable = opt;
    darwin.docker.enable = opt;
  };
}
