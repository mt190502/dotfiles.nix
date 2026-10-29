rec {
  services.qbittorrent = {
    enable = true;
    user = "qbittorrent";
    group = "qbittorrent";
    extraArgs = [ "--confirm-legal-notice" ];
    webuiPort = 8080;
    profileDir = "/var/lib/qBittorrent";
    openFirewall = true;
    serverConfig = {
      LegalNotice.Accepted = true;
      BitTorrent.Session = {
        Port = 6881;
        DHT = true;
        PeX = true;
        LSD = true;
        Encryption = 0;
        DefaultSavePath = "/mnt/ssd/data/torrenting";
        TempPath = "${services.qbittorrent.serverConfig.BitTorrent.Session.DefaultSavePath}/.incomplete";
        TempPathEnabled = true;
      };
      Preferences = {
        WebUI = {
          Port = 8080;
          Address = "0.0.0.0";
          LocalHostAuth = true;
          CSRFProtection = true;
          ClickjackingProtection = true;
          HostHeaderValidation = true;
        };
        General.Locale = "en";
      };
    };
  };
  networking.firewall.allowedTCPPorts = [
    services.qbittorrent.serverConfig.Preferences.WebUI.Port
    services.qbittorrent.serverConfig.BitTorrent.Session.Port
  ];
  networking.firewall.allowedUDPPorts = [
    services.qbittorrent.serverConfig.BitTorrent.Session.Port
  ];
  systemd.tmpfiles.rules = [
    "d ${services.qbittorrent.serverConfig.BitTorrent.Session.DefaultSavePath} 0755 qbittorrent qbittorrent -"
    "d ${services.qbittorrent.serverConfig.BitTorrent.Session.DefaultSavePath}/.incomplete 0755 qbittorrent qbittorrent -"
  ];
}
