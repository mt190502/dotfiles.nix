{
  lib,
  ...
}:

let
  discoverPackages =
    dir:
    let
      entries = builtins.readDir dir;
      entryNames = builtins.attrNames entries;
      processEntry =
        name:
        if entries.${name} == "directory" then
          let
            pkgPath = "${dir}/${name}/default.nix";
          in
          if builtins.pathExists pkgPath then { ${name} = import pkgPath; } else { }
        else if name == "flake-module.nix" then
          { }
        else if lib.hasSuffix ".nix" name then
          { ${lib.removeSuffix ".nix" name} = import "${dir}/${name}"; }
        else
          { };
    in
    builtins.foldl' (acc: name: acc // (processEntry name)) { } entryNames;
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages = lib.filterAttrs (_: drv: pkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform drv) (
        lib.mapAttrs (_: pkg: pkgs.callPackage pkg { }) (discoverPackages ./.)
      );
    };
  flake.overlays.default = final: prev: (discoverPackages ./.);
}
