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
  options.sharing.profiles = {
    nixos = lib.mkOption {
      type = lib.types.attrs;
      description = "A set of NixOS profiles to share. Each user should have a directory with their name, and inside that directory, you can have a default.nix file that defines the NixOS profile for that user.";
      default = { };
    };
    darwin = lib.mkOption {
      type = lib.types.attrs;
      description = "A set of Darwin profiles to share. Each user should have a directory with their name, and inside that directory, you can have a default.nix file that defines the Darwin profile for that user.";
      default = { };
    };
    home = lib.mkOption {
      type = lib.types.attrs;
      description = "A set of Home Manager profiles to share. Each user should have a directory with their name, and inside that directory, you can have a default.nix file that defines the Home Manager profile for that user.";
      default = { };
    };
  };
  config.sharing.profiles = {
    darwin = discoverProfiles ./darwin;
    home = discoverProfiles ./home;
    nixos = discoverProfiles ./nixos;
  };
}
