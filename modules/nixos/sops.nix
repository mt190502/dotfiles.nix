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
        base = builtins.removeAttrs cfg [
          "sopsFile"
          "key"
          "format"
          "relativePath"
        ];
      in
      {
        name = "${user}/${name}";
        value = {
          sopsFile = cfg.sopsFile;
          key = cfg.key or name;
          format = cfg.format or "yaml";
        }
        // base
        // lib.optionalAttrs (cfg ? relativePath) {
          path = "${homeDir}/${cfg.relativePath}";
        };
      }
    ) userSecrets)
  ) { } (builtins.attrNames secrets);
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];
  sops = {
    defaultSopsFormat = "yaml";
    age.keyFile = "/etc/sops/age/keys.txt";
    age.generateKey = true;
    secrets = flattenSecrets;
  };
}
