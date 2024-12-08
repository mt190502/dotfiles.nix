{ lib, ... }:

{
  options.wpg = {
    enable = lib.mkEnableOption {
      type = lib.types.bool;
      default = true;
      description = "Enable wpg configuration.";
    };
  };
}
