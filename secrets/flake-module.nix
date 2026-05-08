{ lib, inputs, ... }:

let
  discoverSecrets =
    dir: relPath:
    let
      entries = builtins.readDir dir;
      dirs = lib.filterAttrs (_: type: type == "directory") entries;
    in
    lib.mapAttrs (
      name: _:
      let
        secretDir = dir + "/${name}";
        cfg = import (secretDir + "/config.nix");
      in
      (builtins.removeAttrs cfg [ "source" ])
      // {
        sopsFile = "${inputs.self}/${relPath}/${name}/${cfg.source}";
        sopsFormat = "binary";
      }
    ) dirs;

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
