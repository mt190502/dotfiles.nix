{ lib, ... }:

{
  options.moduleopts.darwin.homebrew = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "homebrew";
    };
  };
}
