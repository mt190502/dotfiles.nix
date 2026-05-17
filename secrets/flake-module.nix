{ lib, inputs, ... }:

let
  discoverSecrets =
    dir: relPath:
    let
      entries = builtins.readDir dir;
      dirs = lib.filterAttrs (_: type: type == "directory") entries;
    in
    lib.foldl' lib.mergeAttrs { } (
      lib.mapAttrsToList (
        name: _:
        let
          secretDir = dir + "/${name}";
          cfg = import (secretDir + "/config.nix");
          base =
            builtins.removeAttrs cfg [
              "source"
              "format"
              "keys"
            ]
            // {
              sopsFile = "${inputs.self}/${relPath}/${name}/${cfg.source}";
              sopsFormat = cfg.format or "binary";
            };
        in
        if cfg ? keys && cfg.keys != [ ] then
          lib.listToAttrs (
            map (key: {
              name = "${name}/${key}";
              value = base // {
                inherit key;
              };
            }) cfg.keys
          )
        else
          { ${name} = base; }
      ) dirs
    );

  globalSecrets =
    let
      globalDir = ./. + "/global";
    in
    if builtins.pathExists globalDir then discoverSecrets globalDir "secrets/global" else { };

  users = lib.filterAttrs (
    name: type: type == "directory" && name != "template" && name != "global"
  ) (builtins.readDir ./.);
in
{
  options.sharing.secrets = lib.mkOption {
    type = lib.types.attrs;
    description = ''
      A set of secrets to share.
      - User-specific secrets: secrets/<username>/<secret>/config.nix
      - Global secrets: secrets/global/<secret>/config.nix
    '';
    default = { };
  };
  config.sharing.secrets =
    lib.mapAttrs (user: _: discoverSecrets (./. + "/${user}") "secrets/${user}") users
    // {
      global = globalSecrets;
    };
}
