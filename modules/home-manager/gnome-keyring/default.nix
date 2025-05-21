{
  config,
  lib,
  ...
}:

let
  cfg = config.moduleopts.home-manager.gnome-keyring;
in
{
  options.moduleopts.home-manager.gnome-keyring = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "gnome-keyring";
    };
  };
  config = lib.mkIf cfg.enable {
    services.gnome-keyring = {
      enable = true;
      components = [
        "pkcs11"
        "secrets"
        "ssh"
      ];
    };
  };
}
