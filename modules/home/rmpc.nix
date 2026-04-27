{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.services.mpd.enable {
    preferences.mediaplayer = lib.mkDefault "rmpc";
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
          keybinds: (
            global: {
              "<Left>":  SeekBack,
              "<Right>": SeekForward,
              "<S-Tab>": PreviousTab,
              "<Tab>":   NextTab,
              "<":       PreviousTrack,
              ">":       NextTrack,
              "1":       SwitchToTab("Playlist"),
              "2":       SwitchToTab("Directories"),
              "3":       SwitchToTab("Artists"),
              "4":       SwitchToTab("Album Artists"),
              "5":       SwitchToTab("Albums"),
              "6":       SwitchToTab("Playlists"),
              "7":       SwitchToTab("Search"),
              "8":       ShowOutputs,
              "9":       ToggleConsume,
              "0":       ToggleSingle,
              ":":       CommandMode,
              "I":       ShowCurrentSongInfo,
              "d":       ExternalCommand(
                command:     ["${config.xdg.configHome}/rmpc/delete_current_song.sh"],
                description: "Delete current song",
              ),
              "p":       TogglePause,
              "q":       Quit,
              "u":       Update,
              "x":       ToggleRandom,
              "z":       ToggleRepeat,
              ${lib.optionalString (lib.hasSuffix "linux" pkgs.stdenv.hostPlatform.system) ''
                ",":       ExternalCommand(
                  command:     ["${config.xdg.configHome}/rmpc/get_and_copy_purl_from_current_song.sh"],
                  description: "Get and copy PURL from current song",
                ),
              ''}
            },
            navigation: {
              "<CR>":       Confirm,
              "<Down>":     Down,
              "<End>":      Bottom,
              "<Esc>":      Close,
              "<Home>":     Top,
              "<Left>":     Left,
              "<Right>":    Right,
              "<Space>":    Select,
              "<Up>":       Up,
              "G":          Bottom,
              "J":          MoveDown,
              "K":          MoveUp,
              "N":          PreviousResult,
              "g":          Top,
              "j":          Down,
              "k":          Up,
              "n":          NextResult,
              "/":          EnterSearch,
            },
            queue: {
              "<CR>": Play,
              "a":    AddToPlaylist,
              "c":    DeleteAll,
              "s":    Save,
            },
          ),
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
               name: "Playlist",
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
          theme: Some("mt190502"),
          volume_step: 5,
        )
      '';
    };

    xdg.configFile = {
      "rmpc/themes/mt190502.ron" = {
        text = ''
          #![enable(implicit_some)]
          #![enable(unwrap_newtypes)]
          #![enable(unwrap_variant_newtypes)]
          (
            default_album_art_path: None,
            show_song_table_header: true,
            draw_borders: true,
            format_tag_separator: " | ",
            browser_column_widths: [20, 38, 42],
            background_color: None,
            text_color: None,
            header_background_color: None,
            modal_background_color: None,
            modal_backdrop: false,
            preview_label_style: (fg: "yellow"),
            preview_metadata_group_style: (fg: "yellow", modifiers: "Bold"),
            tab_bar: (
              active_style: (fg: "black", bg: "blue", modifiers: "Bold"),
              inactive_style: (),
            ),
            highlighted_item_style: (fg: "blue", modifiers: "Bold"),
            current_item_style: (fg: "black", bg: "blue", modifiers: "Bold"),
            borders_style: (fg: "blue"),
            highlight_border_style: (fg: "blue"),
            symbols: (
              song: "S",
              dir: "D",
              playlist: "P",
              marker: "*",
              ellipsis: "...",
              song_style: None,
              dir_style: None,
              playlist_style: None,
            ),
            level_styles: (
              info: (fg: "blue", bg: "black"),
              warn: (fg: "yellow", bg: "black"),
              error: (fg: "red", bg: "black"),
              debug: (fg: "light_green", bg: "black"),
              trace: (fg: "magenta", bg: "black"),
            ),
            progress_bar: (
              symbols: ["[", "=", "O", "-", "]"],
              track_style: (fg: "white"),
              elapsed_style: (fg: "white"),
              thumb_style: (fg: "white"),
              use_track_when_empty: false,
            ),
            scrollbar: (
              symbols: ["│", "█", "▲", "▼"],
              track_style: (),
              ends_style: (),
              thumb_style: (fg: "blue"),
            ),
            song_table_format: [
              (
                prop: (kind: Property(Artist),
                   default: (kind: Text("Unknown"))
                ),
                width: "20%",
              ),
              (
                prop: (kind: Property(Title),
                  default: (kind: Text("Unknown"))
                ),
                width: "35%",
              ),
              (
                prop: (kind: Property(Album), style: (fg: "white"),
                  default: (kind: Text("Unknown Album"), style: (fg: "white"))
                ),
                width: "30%",
              ),
              (
                prop: (kind: Property(Duration),
                  default: (kind: Text("-"))
                ),
                width: "15%",
                alignment: Right,
              ),
            ],
            components: {},
            layout: Split(
              direction: Vertical,
              panes: [
                (
                  pane: Split(
                    direction: Horizontal,
                    panes: [
                      (size: "70%", pane: Pane(Property(
                         align: Left,
                         scroll_speed: 0,
                         content: [
                          (
                            kind: Group([
                              (kind: Property(Status(ActiveTab))),
                              (kind: Text(" (")),
                              (kind: Property(Status(QueueLength(thousands_separator: ",")))),
                              (kind: Text(" items, length: ")),
                              (kind: Property(Status(QueueTimeTotal(separator: " ")))),
                              (kind: Text(")")),
                            ]),
                          ),
                        ],
                      ))),
                      (size: "30%", pane: Pane(Property(
                        align: Right,
                        scroll_speed: 0,
                        content: [
                          (
                            kind: Group([
                              (kind: Property(Widget(Volume)), style: (fg: "white")),
                            ]),
                          ),
                        ],
                      ))),
                    ],
                  ),
                  size: "2",
                ),
                (
                  pane: Pane(TabContent),
                  size: "100%",
                ),
                (
                  pane: Split(
                    direction: Vertical,
                    panes: [
                      (size: "1", pane: Pane(ProgressBar)),
                      (
                        size: "1",
                        pane: Split(
                          direction: Horizontal,
                          panes: [
                            (
                              size: "70%",
                              pane: Pane(
                                Property(
                                  align: Left,
                                  scroll_speed: 0,
                                  content: [
                                    (
                                      kind: Group([
                                        (kind: Property(Status(State))),
                                        (kind: Text(": ")),
                                        (kind: Property(Song(Artist)), default: (kind: Text("Unknown Artist"))),
                                        (kind: Text(" \"")),
                                        (kind: Property(Song(Album)), default: (kind: Text("Unknown Album"))),
                                        (kind: Text("\" (")),
                                        (kind: Property(Song(Other("date"))), default: (kind: Text("Unknown Year"))),
                                        (kind: Text(") - ")),
                                        (kind: Property(Song(Title)), style: (modifiers: "Bold"), default: (kind: Text("No Song"))),
                                      ]),
                                    ),
                                  ],
                                )
                              ),
                            ),
                            (
                              size: "30%",
                              pane: Pane(
                                Property(
                                  align: Right,
                                  scroll_speed: 0,
                                  content: [
                                    (
                                      kind: Group([
                                        (kind: Text("(")),
                                        (kind: Property(Status(Bitrate))),
                                        (kind: Text(" kbps) [")),
                                        (kind: Property(Status(Elapsed))),
                                        (kind: Text("/")),
                                        (kind: Property(Status(Duration))),
                                        (kind: Text("]")),
                                      ]),
                                      style: (fg: "blue"),
                                    ),
                                  ],
                                )
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  size: "2",
                ),
              ],
            ),
            browser_song_format: [
              (
                kind: Group([
                  (kind: Property(Track)),
                  (kind: Text(" ")),
                ])
              ),
              (
                kind: Group([
                  (kind: Property(Artist)),
                  (kind: Text(" - ")),
                  (kind: Property(Title)),
                ]),
                default: (kind: Property(Filename))
              ),
            ],
            header: (
              rows: [],
            ),
            lyrics: (
              timestamp: false
            ),
          )
        '';
      };
      "rmpc/get_and_copy_purl_from_current_song.sh" =
        lib.mkIf (lib.hasSuffix "linux" pkgs.stdenv.hostPlatform.system)
          {
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
