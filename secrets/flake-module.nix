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
      (import (userDir + "/${name}/config.nix"))
      // {
        sopsFile = "${inputs.self}/secrets/${user}/${name}/secret.yml";
      }
    ) dirs;
  users = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.);
in
{
  flake.secrets = lib.mapAttrs (user: _: discoverSecrets user) users;
}
