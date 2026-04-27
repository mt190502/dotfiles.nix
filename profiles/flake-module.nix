{
  lib,
  ...
}:

let
  discoverProfiles =
    dir:
    let
      entries = builtins.readDir dir;
      entryNames = builtins.attrNames entries;
      processEntry =
        name:
        if entries.${name} == "directory" then
          let
            profilePath = "${dir}/${name}/default.nix";
          in
          if builtins.pathExists profilePath then { ${name} = import profilePath; } else { }
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
  flake = {
    darwinProfiles = discoverProfiles ./darwin;
    homeProfiles = discoverProfiles ./home;
    nixosProfiles = discoverProfiles ./nixos;
  };
}
