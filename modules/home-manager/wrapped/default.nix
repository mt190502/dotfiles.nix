{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wrapped;

  packages = lib.pipe ./. [
    builtins.readDir
    (lib.filterAttrs (n: v: v == "regular" && n != "default.nix"))
    (lib.mapAttrs' (
      n: _:
      let
        pkg = import (./. + "/${n}") { inherit config pkgs; };
      in
      lib.nameValuePair pkg.name pkg
    ))
  ];

  opts = lib.mapAttrs (
    _: pkg:
    lib.mkOption {
      type = lib.types.package;
      default = pkg.original;
    }
  ) packages;
in
{
  options.wrapped = {
    enable = lib.mkEnableOption "Enable nixGL and custom wrapped packages";
  } // opts;

  config = lib.mkIf cfg.enable {
    wrapped = lib.mapAttrs (_: pkg: pkg.wrap) packages;
  };
}
