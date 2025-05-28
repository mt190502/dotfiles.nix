{ lib, ... }:

{
  options.moduleopts.nixos.pipewire = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "pipewire";
    };
  };
}
