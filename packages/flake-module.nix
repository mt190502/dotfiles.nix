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
          if builtins.pathExists pkgPath then
            { ${name} = import pkgPath; }
          else
            let
              subdir = builtins.readDir "${dir}/${name}";
              isPkg = n: lib.hasSuffix ".nix" n && n != "module.nix" && n != "flake-module.nix";
              subPkgs = builtins.foldl' (
                acc: n:
                let
                  path = "${dir}/${name}/${n}";
                  key = if n == "main.nix" then name else name + "-" + lib.removeSuffix ".nix" n;
                in
                if !isPkg n then acc else acc // { ${key} = import path; }
              ) { } (builtins.attrNames subdir);
            in
            subPkgs
        else if name == "flake-module.nix" then
          { }
        else if lib.hasSuffix ".nix" name then
          { ${lib.removeSuffix ".nix" name} = import "${dir}/${name}"; }
        else
          { };
    in
    builtins.foldl' (acc: name: acc // (processEntry name)) { } entryNames;
  discovered = discoverPackages ./.;
  dirs = lib.filterAttrs (_: t: t == "directory") (builtins.readDir ./.);
  dirNames = builtins.attrNames dirs;
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
  options.flake.homeModules = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
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
          lib.mapAttrs (_: pkg: pkgs.callPackage pkg { inherit pkgs-unstable; }) discovered
        );
      };
    flake = {
      overlays.default = _: _: discovered;
      nixosModules = builtins.listToAttrs (
        builtins.concatMap (
          n:
          lib.optional (builtins.pathExists "${./.}/${n}/module/nixos.nix") {
            name = n;
            value = import "${./.}/${n}/module/nixos.nix";
          }
        ) dirNames
      );
      homeModules = builtins.listToAttrs (
        builtins.concatMap (
          n:
          if builtins.pathExists "${./.}/${n}/module/home.nix" then
            [
              {
                name = n;
                value = import "${./.}/${n}/module/home.nix";
              }
            ]
          else
            lib.optional (builtins.pathExists "${./.}/${n}/module/hm.nix") {
              name = n;
              value = import "${./.}/${n}/module/hm.nix";
            }
        ) dirNames
      );
      darwinModules = builtins.listToAttrs (
        builtins.concatMap (
          n:
          lib.optional (builtins.pathExists "${./.}/${n}/module/darwin.nix") {
            name = n;
            value = import "${./.}/${n}/module/darwin.nix";
          }
        ) dirNames
      );

    };
  };
}
