{
  config,
  lib,
  pkgs,
  system,
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
    services =
      if (cfg.bundle == "mpd") then
        {
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
              }
            '';
          };
          mpd-discord-rpc = {
            enable = cfg.discordrpc && cfg.enable && (lib.hasSuffix "linux" system);
            settings = {
              hosts = [ "localhost:6600" ];
              format = {
                details = "$title ($date)";
                state = "$artist / $album";
                timestamp = "elapsed";
              };
            };
          };
          mpdris2-rs.enable = true;
        }
      else if (cfg.bundle == "mopidy") then
        {
          mopidy = {
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
        }
      else
        {
          mpd.enable = false;
        };
  };
}
