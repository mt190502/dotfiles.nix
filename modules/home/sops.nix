{
  config,
  inputs,
  lib,
  sharing,
  ...
}:

let
  inherit (sharing) secrets;
  homeUser = config.home.username;
  userSecrets = secrets.${homeUser} or { };
  nonPasswordSecrets = lib.filterAttrs (
    _: cfg: (cfg.type or "default") != "userPassword"
  ) userSecrets;
  flattenSecrets = lib.mapAttrs' (
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
      ];
    in
    {
      name = "${homeUser}/${name}";
      value = {
        inherit (cfg) sopsFile;
        format = cfg.sopsFormat;
      }
      // base
      // lib.optionalAttrs (cfg ? mode) { inherit (cfg) mode; }
      // lib.optionalAttrs (targetPath != null) { path = targetPath; }
      // lib.optionalAttrs (type == "env") { mode = "0400"; };
    }
  ) nonPasswordSecrets;
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];
  sops = {
    defaultSopsFormat = "binary";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    age.generateKey = true;
    secrets = flattenSecrets;
  };
}
