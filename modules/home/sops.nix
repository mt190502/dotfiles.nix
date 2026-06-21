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
  homeUser = config.home.username;
  userSecrets = secrets.${homeUser} or { };
  nonPasswordSecrets = lib.filterAttrs (
    _: cfg: (cfg.type or "default") != "userPassword"
  ) userSecrets;
  filteredUserSecrets = lib.filterAttrs (shouldInclude flakeName) nonPasswordSecrets;
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
      in
      {
        name = "${prefix}/${name}";
        value =
          baseSecret cfg
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
