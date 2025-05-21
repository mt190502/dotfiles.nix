{ lib, ... }:

{
  options.moduleopts.nixos.libvirt = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "libvirt";
    };
  };
}
