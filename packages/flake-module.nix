{
  lib,
  inputs,
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
  discovered = discoverPackages ./.;
in
{
  options.sharing.customPackages = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
      }
    );
    default = lib.mapAttrs (_: _: { enable = true; }) discovered;
  };
  config = {
    sharing.customPackages = lib.mapAttrs (_: _: { enable = true; }) discovered;
    perSystem =
      { pkgs, ... }:
      let
        pkgs-unstable = import inputs.nixpkgs-unstable {
          system = pkgs.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
      in
      {
        packages = lib.filterAttrs (_: drv: pkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform drv) (
          lib.mapAttrs (_: pkg: pkgs.callPackage pkg { inherit pkgs-unstable; }) (discoverPackages ./.)
        );
      };
    flake.overlays.default = _: _: (discoverPackages ./.);
  };
}
