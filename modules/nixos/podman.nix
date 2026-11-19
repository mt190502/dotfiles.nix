{
  config,
  lib,
  pkgs,
  ...
}:

{
  assertions = [
    {
      assertion = lib.all (
        u:
        !(u.isNormalUser or false) || u.autoSubUidGidRange || u.subUidRanges != [ ] || u.subGidRanges != [ ]
      ) (lib.attrValues config.users.users);
      message = "rootless podman: a normal user has no subordinate uid/gid ranges";
    }
  ];
  environment.systemPackages = [ pkgs.docker-compose ];
  systemd = {
    sockets.podman.enable = false;
    services.podman.enable = false;
  };
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
