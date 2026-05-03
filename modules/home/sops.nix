{
  inputs,
  config,
  lib,
  ...
}:

let
  secrets = inputs.self.secrets or { };
  homeUser = config.home.username;
  userSecrets = secrets.${homeUser} or { };
  nonPasswordSecrets = lib.filterAttrs (_: cfg: (cfg.type or "default") != "userPassword") userSecrets;
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
        else if cfg ? globalTarget then
          cfg.globalTarget
        else
          null;
      base = builtins.removeAttrs cfg [
        "type"
        "sopsFile"
        "sopsFormat"
        "source"
        "homeTarget"
        "globalTarget"
        "mode"
        "neededForUsers"
      ];
    in
    {
      name = "${homeUser}/${name}";
      value = {
        sopsFile = cfg.sopsFile;
        format = cfg.sopsFormat;
      }
      // base
      // lib.optionalAttrs (cfg ? mode) { mode = cfg.mode; }
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
