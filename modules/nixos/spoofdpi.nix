{ lib, pkgs, ... }:

{
  systemd.services.spoofdpi = {
    description = "SpoofDPI - A tool to bypass Deep Packet Inspection (DPI) censorship";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${lib.getExe' pkgs.spoofdpi "spoofdpi"} ${
         lib.concatStringsSep " " [
           "--default-ttl 64"
           "--dns-mode https"
           "--dns-https-url https://one.one.one.one/dns-query"
           "--dns-addr 1.1.1.1:53"
           "--https-split-mode sni"
           "--https-fake-count 5"
           "--https-disorder true"
           "--log-level debug"
           "--system-proxy true"
         ]
      }";
      Restart = "on-failure";
      User = "root";
    };
  };
}
