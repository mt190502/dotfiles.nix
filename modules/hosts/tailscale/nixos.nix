{ config, lib, ... }:

let
  cfg = config.moduleopts.nixos.tailscale;
in
{
  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      extraUpFlags = [
        "--accept-dns"
        "--accept-routes"
        "--ssh"
      ];
    };
  };
}
