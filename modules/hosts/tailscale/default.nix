{ lib, ... }:

{
  options.moduleopts.nixos.tailscale = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "tailscale";
    };
  };
}
