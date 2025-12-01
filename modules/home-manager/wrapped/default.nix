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
    (lib.filterAttrs (n: _: n != "default.nix"))
    (lib.mapAttrs' (
      n: _:
      let
        pkg = import (./. + "/${n}") { inherit config pkgs pkgs-unstable; };
      in
      lib.nameValuePair (lib.removeSuffix ".nix" n) pkg
    ))
  ];
  opts = lib.mapAttrs (
    _: pkg:
    lib.mkOption {
      type = lib.types.package;
      default = pkg;
    }
  ) packages;
in
{
  options.wrapped = opts;
  config.wrapped = lib.mapAttrs (_: pkg: pkg) packages;
}
