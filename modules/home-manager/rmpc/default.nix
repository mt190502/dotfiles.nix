{
  config,
  lib,
  pkgs,
  system,
  ...
}:

let
  cfg = config.moduleopts.home-manager.rmpc;
in
{
  options.moduleopts.home-manager.rmpc = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "rmpc";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.cava.enable = true;
    programs.rmpc = {
      enable = true;
      config = ''
        #![enable(implicit_some)]
        #![enable(unwrap_newtypes)]
        #![enable(unwrap_variant_newtypes)]
        (
          address: "127.0.0.1:6600",
          album_art: (
            method: Auto,
            max_size_px: (width: 1200, height: 1200),
            disabled_protocols: ["http://", "https://"],
            vertical_align: Center,
            horizontal_align: Center,
          ),
          artists: (
            album_display_mode: SplitByDate,
            album_sort_by: Date,
          ),
          browser_song_sort: [Disc, Track, Artist, Title],
          cava: (
            framerate: 60,
            autosens: true,
            sensitivity: 100,
            lower_cutoff_freq: 50,
            higher_cutoff_freq: 10000,
            input: (
              method: Fifo,
              source: "/tmp/mpd.fifo",
              sample_rate: 44100,
              channels: 2,
              sample_bits: 16,
            ),
            smoothing: (
              noise_reduction: 77,
              monstercat: false,
              waves: false,
            ),
          ),
          center_current_song_on_change: true,
          directories_sort: SortFormat(group_by_type: true, reverse: false),
          enable_config_hot_reload: true,
          password: None,
          search: (
            case_sensitive: false,
            mode: Contains,
            tags: [
              (value: "any",          label: "Any Tag"),
              (value: "artist",       label: "Artist"),
              (value: "album",        label: "Album"),
              (value: "albumartist",  label: "Album Artist"),
              (value: "title",        label: "Title"),
              (value: "filename",     label: "Filename"),
              (value: "genre",        label: "Genre"),
            ],
          ),
          select_current_song_on_change: true,
          tabs: [
            (
              name: "Queue",
              pane: Split(
                direction: Horizontal,
                panes: [
                  (size: "25%", pane: Pane(AlbumArt)),
                  (size: "75%", pane: Pane(Queue)),
                ],
              ),
            ),
            ( name: "Directories", pane: Pane(Directories) ),
            ( name: "Artists", pane: Pane(Artists) ),
            ( name: "Album Artists", pane: Pane(AlbumArtists) ),
            ( name: "Albums", pane: Pane(Albums) ),
            ( name: "Playlists", pane: Pane(Playlists) ),
            ( name: "Search", pane: Pane(Search) ),
          ],
          theme: None,
          volume_step: 5,
        )
      '';
    };

    xdg.configFile = {
      "rmpc/get_and_copy_purl_from_current_song.sh" = lib.mkIf (lib.hasSuffix "linux" system) {
        text = ''
          #!${lib.getExe' pkgs.bash "bash"}
          current_song_file_path="${config.services.mpd.musicDirectory}/$(${lib.getExe pkgs.mpc} current -f %file%)"
          purl=$(${lib.getExe' pkgs.ffmpeg "ffprobe"} -v quiet -show_entries stream_tags=purl -of default=noprint_wrappers=1:nokey=1 "$current_song_file_path")
          if [ -n "$purl" ]; then
            echo "$purl" | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}
            ${lib.getExe pkgs.libnotify} "rmpc: PURL copied to clipboard" "$purl"
          fi
        '';
        executable = true;
      };

      "rmpc/delete_current_song.sh" = {
        text = ''
          #!${lib.getExe' pkgs.bash "bash"}
          current_song_file_path="${config.services.mpd.musicDirectory}/$(${lib.getExe pkgs.mpc} current -f %file%)"
          ${lib.getExe' pkgs.trash-cli "trash"} -f "$current_song_file_path" && {
            ${lib.getExe pkgs.libnotify} "rmpc: Song moved to trash" "Moved $current_song_file_path to trash"
          } || {
            ${lib.getExe pkgs.libnotify} "rmpc: Failed to delete current song" "Could not delete $current_song_file_path"
          }
          ${lib.getExe pkgs.mpc} update >/dev/null 2>&1
          ${lib.getExe pkgs.mpc} next >/dev/null 2>&1
        '';
        executable = true;
      };
    };
  };
}
