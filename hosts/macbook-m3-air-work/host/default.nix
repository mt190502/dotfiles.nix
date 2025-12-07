{ lib, ... }:
## Import all modules inside this folder recursively.
## from: https://github.com/evanjs/nixos_cfg/blob/4bb5b0b84a221b25cf50853c12b9f66f0cad3ea4/config/new-modules/default.nix
let
  getDir =
    dir:
    lib.mapAttrs (file: type: if type == "directory" then getDir "${dir}/${file}" else null) (
      builtins.readDir dir
    );
  files =
    dir:
    lib.collect lib.isString (
      lib.mapAttrsRecursive (path: _: lib.concatStringsSep "/" path) (getDir dir)
    );
  validFiles =
    dir:
    map (file: ./. + "/${file}") (
      lib.filter (file: lib.hasSuffix "default.nix" file && file != "default.nix") (files dir)
    );
in
{
  imports = validFiles ./.;
}
