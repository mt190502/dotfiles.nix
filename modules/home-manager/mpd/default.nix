{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager.mpd;
  home = config.home.homeDirectory;
in
{
  options.moduleopts.home-manager.mpd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "mpd";
    };
    discordrpc = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "discord-rpc";
    };
    bundle = lib.mkOption {
      type = lib.types.enum [
        "mpd"
        "mopidy"
      ];
      default = "mpd";
      description = "bundle to use";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mpd = {
      enable = cfg.bundle == "mpd";
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
        }
      '';
    };

    home.packages = lib.mkIf (cfg.bundle == "mpd") [
      inputs.self.packages."${pkgs.system}".mpdris2-rs
    ];
    systemd.user.services.mpdris2-rs = lib.mkIf (cfg.bundle == "mpd") {
      Unit = {
        Description = "Music Player Daemon D-Bus Bridge";
        Wants = "mpd.service";
        After = "mpd.service";
      };

      Service = {
        Restart = "on-failure";
        ExecStart = "${inputs.self.packages.${pkgs.system}.mpdris2-rs}/bin/mpdris2-rs";
        BusName = "org.mpris.MediaPlayer2.mpd";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    services.mopidy = {
      enable = cfg.bundle == "mopidy";
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
      #  "${home}/.config/mopidy/jellyfin.conf"
      #];
    };

    services.mpd-discord-rpc = {
      enable = cfg.discordrpc && cfg.enable;
      settings = {
        hosts = [ "localhost:6600" ];
        format = {
          details = "$title ($date)";
          state = "$artist / $album";
          timestamp = "elapsed";
        };
      };
    };
  };
}
