{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager.ncmpcpp;
in
{
  options.moduleopts.home-manager.ncmpcpp = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "ncmpcpp";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.ncmpcpp = {
      enable = true;
      settings = {
        allow_for_physical_item_deletion = true;
        ask_before_clearing_playlists = false;
        autocenter_mode = true;
        browser_display_mode = "columns";
        centered_cursor = true;
        clock_display_seconds = true;
        connected_message_on_startup = false;
        # current_item_inactive_column_prefix = ""
        # current_item_inactive_column_suffix = "";
        # current_item_prefix = "";
        # current_item_suffix = "";
        default_find_mode = "wrapped";
        default_place_to_search_in = "database";
        discard_colors_if_item_is_selected = false;
        display_bitrate = true;
        display_remaining_time = true;
        display_volume_level = true;
        enable_window_title = true;
        fetch_lyrics_for_current_song_in_background = false;
        follow_now_playing_lyrics = true;
        jump_to_now_playing_song_at_start = true;
        lines_scrolled = 1;
        # lyrics_directory = "PATH";
        # lyrics_fetchers = "FETCHERS";
        # mouse_list_scroll_whole_page = false;
        # now_playing_prefix = "";
        # now_playing_suffix = "";
        playlist_disable_highlight_delay = 0;
        playlist_separate_albums = false;
        playlist_show_remaining_time = false;
        progressbar_color = "yellow";
        progressbar_elapsed_color = "white";
        progressbar_look = "=O";
        regular_expressions = "perl";
        search_engine_display_mode = "columns";
        show_hidden_files_in_local_browser = false;
        store_lyrics_in_song_dir = true;
        volume_change_step = 5;
      };
      bindings = [
        {
          key = "d";
          command = "run_external_command \"$XDG_CONFIG_HOME/ncmpcpp/delete_current_song.sh\"";
        }
        {
          key = ",";
          command = "run_external_command \"$XDG_CONFIG_HOME/ncmpcpp/get_and_copy_purl_from_current_song.sh\"";
        }
      ];
    };
    xdg.configFile = {
      "ncmpcpp/get_and_copy_purl_from_current_song.sh" = {
        text = ''
          #!${lib.getExe' pkgs.bash "bash"}
          current_song_file_path="${config.services.mpd.musicDirectory}/$(${lib.getExe pkgs.mpc} current -f %file%)"
          purl=$(${lib.getExe' pkgs.ffmpeg "ffprobe"} -v quiet -show_entries stream_tags=purl -of default=noprint_wrappers=1:nokey=1 "$current_song_file_path")
          if [ -n "$purl" ]; then
            echo "$purl" | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}
            ${lib.getExe pkgs.libnotify} "ncmpcpp: PURL copied to clipboard" "$purl"
          fi
        '';
        executable = true;
      };
      "ncmpcpp/delete_current_song.sh" = {
        text = ''
          #!${lib.getExe' pkgs.bash "bash"}
          current_song_file_path="${config.services.mpd.musicDirectory}/$(${lib.getExe pkgs.mpc} current -f %file%)"
          ${lib.getExe' pkgs.trash-cli "trash"} -f "$current_song_file_path" && {
            ${lib.getExe pkgs.libnotify} "ncmpcpp: Song moved to trash" "Moved $current_song_file_path to trash"
          } || {
            ${lib.getExe pkgs.libnotify} "ncmpcpp: Failed to delete current song" "Could not delete $current_song_file_path"
          }
          ${lib.getExe pkgs.mpc} update >/dev/null 2>&1
          ${lib.getExe pkgs.mpc} next >/dev/null 2>&1
        '';
        executable = true;
      };
    };
  };
}
