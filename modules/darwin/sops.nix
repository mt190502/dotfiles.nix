{
  inputs,
  config,
  lib,
  ...
}:

let
  secrets = inputs.self.secrets or { };
  flattenSecrets = lib.foldl' (
    acc: user:
    let
      userSecrets = secrets.${user} or { };
      homeDir = config.users.users.${user}.home;
    in
    acc
    // (lib.mapAttrs' (
      name: cfg:
      let
        type = cfg.type or "default";
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
        ];
      in
      {
        name = "${user}/${name}";
        value = {
          sopsFile = cfg.sopsFile;
          format = cfg.sopsFormat;
          owner = user;
        }
        // base
        // lib.optionalAttrs (cfg ? mode) { mode = cfg.mode; }
        // lib.optionalAttrs (targetPath != null) { path = targetPath; }
        // lib.optionalAttrs (type == "password") { neededForUsers = true; }
        // lib.optionalAttrs (type == "env") { mode = "0400"; };
      }
    ) userSecrets)
  ) { } (builtins.attrNames secrets);
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
