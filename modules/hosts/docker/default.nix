{ lib, ... }:

{
  options.moduleopts.nixos.docker = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "docker";
    };
  };
}
