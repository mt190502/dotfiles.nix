{
  config,
  flakeName,
  inputs,
  lib,
  sharing,
  ...
}:

let
  inherit (import "${inputs.self}/lib/sops.nix") shouldInclude baseSecret;
  inherit (sharing) secrets;
  globalSecrets = lib.filterAttrs (shouldInclude flakeName) (secrets.global or { });
  processGlobalSecrets = lib.mapAttrs' (
    name: cfg:
    let
      targetPath = cfg.globalTarget or null;
    in
    {
      name = "global/${name}";
      value =
        baseSecret cfg
        // lib.optionalAttrs (cfg ? mode) { inherit (cfg) mode; }
        // lib.optionalAttrs (cfg ? group) { inherit (cfg) group; }
        // lib.optionalAttrs (targetPath != null) { path = targetPath; };
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
        lib.filterAttrs (shouldInclude flakeName) (secrets.${userName} or { })
      );
    in
    acc
    // (lib.mapAttrs' (name: cfg: {
      name = "${userName}/${name}";
      value =
        (baseSecret cfg)
        // {
          owner = userName;
          neededForUsers = true;
        }
        // lib.optionalAttrs (cfg ? mode) { inherit (cfg) mode; }
        // lib.optionalAttrs (cfg ? group) { inherit (cfg) group; };
    }) userPasswordSecrets)
  ) { } userEntries;

  systemdConfigs =
    let
      stripSuffix = unit: lib.removeSuffix ".service" unit;
      secretsWithRestart = lib.filterAttrs (_: cfg: cfg ? restartUnits) globalSecrets;
      secretsWithReload = lib.filterAttrs (_: cfg: cfg ? reloadUnits) globalSecrets;
    in
    lib.foldl' lib.mergeAttrs { } (
      (lib.concatMap (
        name:
        let
          cfg = globalSecrets.${name};
          secretPath = config.sops.secrets.${name}.path;
        in
        map (unit: {
          ${stripSuffix unit}.restartTriggers = [ secretPath ];
        }) (cfg.restartUnits or [ ])
      ) (builtins.attrNames secretsWithRestart))
      ++ (lib.concatMap (
        name:
        let
          cfg = globalSecrets.${name};
          secretPath = config.sops.secrets.${name}.path;
        in
        map (unit: {
          ${stripSuffix unit}.reloadTriggers = [ secretPath ];
        }) (cfg.reloadUnits or [ ])
      ) (builtins.attrNames secretsWithReload))
    );
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
  systemd.services = systemdConfigs;
}
