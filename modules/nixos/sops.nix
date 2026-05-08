{
  config,
  inputs,
  lib,
  sharing,
  ...
}:

let
  inherit (sharing) secrets;
  systemUsers = builtins.attrNames config.users.users;
  validEntries = builtins.filter (entry: entry == "global" || builtins.elem entry systemUsers) (
    builtins.attrNames secrets
  );
  flattenSecrets = lib.foldl' (
    acc: entry:
    let
      isGlobal = entry == "global";
      owner = if isGlobal then null else entry;
      homeDir = if isGlobal then null else config.users.users.${entry}.home;
      entrySecrets = secrets.${entry} or { };
    in
    acc
    // (lib.mapAttrs' (
      name: cfg:
      let
        type = cfg.type or "default";
        targetPath =
          if isGlobal then
            cfg.globalTarget or null
          else if type == "env" then
            "${homeDir}/.config/environment.d/${name}.conf"
          else if cfg ? homeTarget then
            "${homeDir}/${cfg.homeTarget}"
          else
            cfg.globalTarget or null;
        base = builtins.removeAttrs cfg [
          "type"
          "sopsFile"
          "sopsFormat"
          "source"
          "homeTarget"
          "globalTarget"
          "mode"
          "group"
          "restartUnits"
          "reloadUnits"
          "neededForUsers"
        ];
      in
      {
        name = "${entry}/${name}";
        value = {
          inherit (cfg) sopsFile;
          format = cfg.sopsFormat;
        }
        // lib.optionalAttrs (owner != null) { inherit owner; }
        // base
        // lib.optionalAttrs (cfg ? mode) { inherit (cfg) mode; }
        // lib.optionalAttrs (cfg ? group) { inherit (cfg) group; }
        // lib.optionalAttrs (targetPath != null) { path = targetPath; }
        // lib.optionalAttrs (!isGlobal && type == "userPassword") { neededForUsers = true; }
        // lib.optionalAttrs (!isGlobal && type == "env") { mode = "0400"; }
        // lib.optionalAttrs (cfg ? restartUnits) { inherit (cfg) restartUnits; }
        // lib.optionalAttrs (cfg ? reloadUnits) { inherit (cfg) reloadUnits; };
      }
    ) entrySecrets)
  ) { } validEntries;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];
  users.mutableUsers = false;
  sops = {
    defaultSopsFormat = "binary";
    age.keyFile = "/etc/sops/age/keys.txt";
    age.generateKey = true;
    secrets = flattenSecrets;
  };
}
