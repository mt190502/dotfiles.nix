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
  options.sharing.secrets = lib.mkOption {
    type = lib.types.attrs;
    description = "A set of secrets to share. Each user should have a directory with their name, and inside that directory, you can have subdirectories for each secret, each containing a config.nix file that specifies the source file for the secret.";
    default = { };
  };
  config.sharing.secrets = lib.mapAttrs (user: _: discoverSecrets user) users;
}
