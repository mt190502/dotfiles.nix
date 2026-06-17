{ lib }:

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
in
rec {
  importDirRecursive =
    dir:
    map (file: dir + "/${file}") (
      lib.filter (file: lib.hasSuffix "default.nix" file && file != "default.nix") (files dir)
    );
  importSubdirs = dir: {
    imports = importDirRecursive dir;
  };
  importUserDirs =
    dir:
    let
      userDirs = builtins.attrNames (builtins.readDir dir);
      validUsers = builtins.filter (name: builtins.pathExists (dir + "/${name}/default.nix")) userDirs;
    in
    {
      home-manager.users = builtins.listToAttrs (
        map (name: {
          inherit name;
          value = import (dir + "/${name}");
        }) validUsers
      );
    };
}
