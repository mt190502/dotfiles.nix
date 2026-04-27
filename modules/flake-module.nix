{
  lib,
  ...
}:

let
  discoverModules =
    dir:
    let
      entries = builtins.readDir dir;
      entryNames = builtins.attrNames entries;
      processEntry =
        name:
        if entries.${name} == "directory" then
          let
            submodulePath = "${dir}/${name}/default.nix";
          in
          if builtins.pathExists submodulePath then { ${name} = import submodulePath; } else { }
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
    nixosModules = discoverModules ./nixos;
    darwinModules = discoverModules ./darwin;
    homeModules = discoverModules ./home;
  };
}
