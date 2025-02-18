{ config, ... }:

{
  services.mpd = {
    enable = false;
    package = config.wrappedPkgs.mpd;
    dataDir = "${config.home.homeDirectory}/.cache/mpd";
    musicDirectory = "${config.home.homeDirectory}/Music/Artists";
    playlistDirectory = "${config.home.homeDirectory}/Music/Playlists";
    network = {
      listenAddress = "any";
      port = 6600;
      startWhenNeeded = true;
    };
  };
  services.mpdris2 = {
    enable = false;
    notifications = true;
    mpd = {
      host = "localhost";
      port = 6600;
    };
  };
  services.mpd-discord-rpc = {
    enable = false;
    settings = {
      hosts = [ "localhost:6600" ];
      format = {
        details = "$title";
        state = "$artist / $album";
        timestamp = "elapsed";
      };
    };
  };
}
