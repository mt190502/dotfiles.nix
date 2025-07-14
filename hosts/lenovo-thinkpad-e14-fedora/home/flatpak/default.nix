{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager.flatpak;
in
{
  config = lib.mkIf cfg.enable {
    services.flatpak.packages = [
      "io.gitlab.librewolf-community"
    ];
  };
}
