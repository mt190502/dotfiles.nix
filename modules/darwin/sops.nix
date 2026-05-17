{
  config,
  flakeName,
  inputs,
  lib,
  sharing,
  ...
}:

let
  inherit (sharing) secrets;
  matchHost =
    hostName: patterns:
    builtins.any (
      pat: builtins.match (builtins.replaceStrings [ "*" ] [ ".*" ] pat) hostName != null
    ) patterns;
  shouldInclude =
    _: cfg:
    let
      hosts = cfg.hosts or [ ];
      excludeHosts = cfg.excludeHosts or [ ];
      inHosts = hosts == [ ] || matchHost flakeName hosts;
      inExclude = matchHost flakeName excludeHosts;
    in
    inHosts && !inExclude;
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
      entrySecrets = lib.filterAttrs shouldInclude (secrets.${entry} or { });
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
          "hosts"
          "excludeHosts"
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
        // lib.optionalAttrs (cfg ? group) { group = if cfg.group == "root" then "wheel" else cfg.group; }
        // lib.optionalAttrs (targetPath != null) { path = targetPath; }
        // lib.optionalAttrs (!isGlobal && type == "userPassword") { neededForUsers = true; }
        // lib.optionalAttrs (!isGlobal && type == "env") { mode = "0400"; };
      }
    ) entrySecrets)
  ) { } validEntries;
in
{
  imports = [ inputs.sops-nix.darwinModules.sops ];
  sops = {
    defaultSopsFormat = "binary";
    age.keyFile = "/etc/sops/age/keys.txt";
    age.generateKey = true;
    secrets = flattenSecrets;
  };
}
