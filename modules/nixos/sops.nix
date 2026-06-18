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
  globalSecrets = lib.filterAttrs shouldInclude (secrets.global or { });
  processGlobalSecrets = lib.mapAttrs' (
    name: cfg:
    let
      targetPath = cfg.globalTarget or null;
      base = removeAttrs cfg [
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
      name = "global/${name}";
      value = {
        inherit (cfg) sopsFile;
        format = cfg.sopsFormat;
      }
      // base
      // lib.optionalAttrs (cfg ? mode) { inherit (cfg) mode; }
      // lib.optionalAttrs (cfg ? group) { inherit (cfg) group; }
      // lib.optionalAttrs (targetPath != null) { path = targetPath; }
      // lib.optionalAttrs (cfg ? restartUnits) { inherit (cfg) restartUnits; }
      // lib.optionalAttrs (cfg ? reloadUnits) { inherit (cfg) reloadUnits; };
    }
  ) globalSecrets;
  globalAliases = lib.mapAttrs' (n: v: {
    name = lib.removePrefix "global/" n;
    value = v;
  }) processGlobalSecrets;
  systemUsers = builtins.attrNames config.users.users;
  userEntries = builtins.filter (entry: entry != "global" && builtins.elem entry systemUsers) (
    builtins.attrNames secrets
  );
  processUserPasswords = lib.foldl' (
    acc: userName:
    let
      userPasswordSecrets = lib.filterAttrs (_: cfg: (cfg.type or "default") == "userPassword") (
        lib.filterAttrs shouldInclude (secrets.${userName} or { })
      );
    in
    acc
    // (lib.mapAttrs' (
      name: cfg:
      let
        base = removeAttrs cfg [
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
        name = "${userName}/${name}";
        value = {
          inherit (cfg) sopsFile;
          format = cfg.sopsFormat;
          owner = userName;
          neededForUsers = true;
        }
        // base
        // lib.optionalAttrs (cfg ? mode) { inherit (cfg) mode; }
        // lib.optionalAttrs (cfg ? group) { inherit (cfg) group; };
      }
    ) userPasswordSecrets)
  ) { } userEntries;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];
  users.mutableUsers = false;
  sops = {
    defaultSopsFormat = "binary";
    age.keyFile = "/etc/sops/age/keys.txt";
    age.generateKey = true;
    secrets = globalAliases // processUserPasswords;
  };
}
