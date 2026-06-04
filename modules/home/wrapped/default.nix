{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  allFiles = lib.pipe ./. [
    builtins.readDir
    (lib.filterAttrs (n: _: n != "default.nix"))
    (lib.mapAttrs' (
      n: _:
      let
        result = import (./. + "/${n}") { inherit config pkgs pkgs-unstable; };
      in
      lib.nameValuePair (lib.removeSuffix ".nix" n) result
    ))
  ];

  isDesktop = config.preferences.desktopenv != "none";

  packages = lib.mapAttrs (_: v: v.package) (
    lib.filterAttrs (_: v: !v.isDesktopPackage || isDesktop) allFiles
  );
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
