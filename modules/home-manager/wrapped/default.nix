{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  packages = lib.pipe ./. [
    builtins.readDir
    (lib.filterAttrs (n: v: v == "regular" && n != "default.nix"))
    (lib.mapAttrs' (
      n: _:
      let
        pkg = import (./. + "/${n}") { inherit config pkgs pkgs-unstable; };
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
    mode = lib.mkOption {
      type = lib.types.enum [
        "nixGL"
        "standard"
        "none"
      ];
      default = "standard";
      description = ''
        The mode to use for wrapping packages. If set to "nixGL", it will use
        the nixGL wrapper. If set to "standard", it will use the wrap without
        the nixGL wrapper.
      '';
    };
  } // opts;
  config.wrapped = lib.mapAttrs (_: pkg: pkg.wrap) packages;
}
