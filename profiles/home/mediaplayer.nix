{ config, ... }:

let
  home = config.home.homeDirectory;
in
{
  services = {
    mpd = {
      enable = true;
      dataDir = "${home}/.cache/mpd";
      musicDirectory = "${home}/Music";
      playlistDirectory = "${home}/Music/Playlists";
      network = {
        listenAddress = "any";
        port = 6600;
        startWhenNeeded = true;
      };
      extraConfig = ''
        audio_output {
          type        "pipewire"
          name        "PipeWire Audio Server"
          enabled     "yes"
        }
        audio_output {
          type        "httpd"
          name        "HTTP Stream (opus)"
          encoder     "opus"
          port        "8000"
          complexity  "10"
          signal      "music"
          vbr         "no"
          bitrate     "max"
          format      "48000:*:2"
          enabled     "yes"
          opustags    "yes"
        }
        audio_output {
          type        "fifo"
          name        "Cava"
          path        "/tmp/mpd.fifo"
          format      "44100:16:2"
          enabled     "yes"
        }
      '';
    };
    mpd-discord-rpc = {
      enable = false;
      settings = {
        hosts = [ "localhost:6600" ];
        format = {
          details = "$title ($date)";
          state = "$artist / $album";
          timestamp = "elapsed";
        };
      };
    };
    mpdris2-rs = {
      enable = true;
      notifications.enable = true;
    };
  };
  systemd.user.services.mpdris2-rs = {
    Install = {
      WantedBy = [ 
        "graphical.target"
        "${config.preferences.desktopenv}-session.target"
      ];
    };
    Unit = {
      Wants = [ "mpd.service" ];
    };
  };
}
