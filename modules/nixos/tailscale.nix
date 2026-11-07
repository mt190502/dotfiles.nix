{
  config,
  flakeName,
  lib,
  ...
}:

let
  tags = if (lib.hasSuffix "server" flakeName) then "tag:servers" else "tag:personal";
in
{
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale".path;
    authKeyParameters = {
      ephemeral = false;
      preauthorized = true;
    };
    extraUpFlags = [
      "--accept-dns"
      "--accept-routes"
      "--ssh"
      "--advertise-tags=${tags}"
    ];
  };
  services.resolved.settings.Resolve.DNS = lib.mkBefore [ "100.100.100.100" ];
}
