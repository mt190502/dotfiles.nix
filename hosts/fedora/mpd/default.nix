{ config, pkgs, ... }:

{
  ### (mpd [active]) ########################################################
  services.mpd = {
    enable = true;
    dataDir = "${config.home.homeDirectory}/.cache/mpd";
    musicDirectory = "${config.home.homeDirectory}/Music";
    playlistDirectory = "${config.home.homeDirectory}/Music/Playlists";
    network = {
      listenAddress = "any";
      port = 6600;
      startWhenNeeded = true;
    };
  };
  services.mpdris2 = {
    enable = true;
    notifications = false;
    mpd = {
      host = "localhost";
      port = 6600;
    };
  };
  ###########################################################################

  ### (mopidy [inactive]) ###################################################
  services.mopidy = {
    enable = false;
    extensionPackages = with pkgs; [
      mopidy-jellyfin
      mopidy-mpd
      mopidy-mpris
    ];
    settings = {
      file = {
        enabled = true;
        media_dirs = [
          "$XDG_MUSIC_DIR|Music"
        ];
        follow_symlinks = true;
        excluded_file_extensions = [
          ".html"
          ".zip"
          ".jpg"
          ".jpeg"
          ".png"
        ];
      };
      mpd = {
        hostname = "::";
      };
    };
    #extraConfigFiles = [
    #  "${config.home.homeDirectory}/.config/mopidy/jellyfin.conf"
    #];
  };
  ###########################################################################

  ### (other) ###############################################################
  services.mpd-discord-rpc = {
    enable = true;
    settings = {
      hosts = [ "localhost:6600" ];
      format = {
        details = "$title";
        state = "$artist / $album";
        timestamp = "elapsed";
      };
    };
  };
  ###########################################################################
}
