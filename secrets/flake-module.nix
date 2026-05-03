{ lib, inputs, ... }:

let
  discoverSecrets =
    user:
    let
      userDir = ./. + "/${user}";
      entries = builtins.readDir userDir;
      dirs = lib.filterAttrs (_: type: type == "directory") entries;
    in
    lib.mapAttrs (
      name: _:
      let
        secretDir = userDir + "/${name}";
        cfg = import (secretDir + "/config.nix");
      in
      (builtins.removeAttrs cfg [ "source" ])
      // {
        sopsFile = "${inputs.self}/secrets/${user}/${name}/${cfg.source}";
        sopsFormat = "binary";
      }
    ) dirs;
  users = lib.filterAttrs (name: type: type == "directory" && name != "template") (
    builtins.readDir ./.
  );
in
{
  flake.secrets = lib.mapAttrs (user: _: discoverSecrets user) users;
}
