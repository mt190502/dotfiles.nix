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
  homeUser = config.home.username;
  userSecrets = secrets.${homeUser} or { };
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
  nonPasswordSecrets = lib.filterAttrs (
    _: cfg: (cfg.type or "default") != "userPassword"
  ) userSecrets;
  filteredUserSecrets = lib.filterAttrs shouldInclude nonPasswordSecrets;
  processSecrets =
    prefix: secrets:
    lib.mapAttrs' (
      name: cfg:
      let
        type = cfg.type or "default";
        homeDir = config.home.homeDirectory;
        targetPath =
          if type == "env" then
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
          "neededForUsers"
          "restartUnits"
          "reloadUnits"
          "hosts"
          "excludeHosts"
        ];
      in
      {
        name = "${prefix}/${name}";
        value = {
          inherit (cfg) sopsFile;
          format = cfg.sopsFormat;
        }
        // base
        // lib.optionalAttrs (cfg ? mode) { inherit (cfg) mode; }
        // lib.optionalAttrs (targetPath != null) { path = targetPath; }
        // lib.optionalAttrs (type == "env") { mode = "0400"; };
      }
    ) secrets;
  userAliases = lib.mapAttrs' (n: v: {
    name = lib.removePrefix "${homeUser}/" n;
    value = v;
  }) (processSecrets homeUser filteredUserSecrets);
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];
  sops = {
    defaultSopsFormat = "binary";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    age.generateKey = true;
    secrets = userAliases;
  };
}
