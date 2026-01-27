{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager.yt-dlp;
  home = config.home.homeDirectory;
in
{
  options.moduleopts.home-manager.yt-dlp = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "yt-dlp";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.yt-dlp = {
      enable = true;
    };
    xdg.configFile."yt-dlp/music/yt-dlp.conf" = {
      text = ''
        --convert-thumbnails jpg
        --embed-metadata
        --embed-thumbnail
        --exec ${home}/.config/yt-dlp/music/modify-and-trim-nonstandard-characters.sh
        --no-mtime
        --ppa "ffmpeg: -c:v mjpeg -vf crop=\"'if(gt(ih,iw),iw,ih)':'if(gt(iw,ih),ih,iw)'\""
        --parse-metadata "playlist_index:%(track_number)s"
        --parse-metadata "%(release_year|)s:%(meta_date)s"
        --parse-metadata "track:(?i)(?P<track>.+)s+(?:([^)]*(?:master|edition|original|mix)[^)]*))s*"
        --parse-metadata "album:(?i)(?P<album>.+)s+(?:([^)]*(?:master|edition)[^)]*))s*"
        --replace-in-metadata 'artist' ',.+' '''
        -f 251
        -x
        -N 8
      '';
    };
    xdg.configFile."yt-dlp/music/modify-and-trim-nonstandard-characters.sh" = {
      text = ''
        #!${lib.getExe pkgs.bash}
        OLDIFS=$IFS
        IFS=$'\n'
        YELLOW='\033[1;33m'
        GREEN='\033[0;32m'
        NC='\033[0m'

        for f in $(find ${home}/Music -depth -name '*[ğüşıöçĞÜŞİÖÇâîûêôÂÎÛÊÔ⧸？&]*'); do
          new=$(echo "$f" | awk -F '/' '{print $NF}' | sed 's/&/feat./g; s/？//g; s/⧸/-/g')
          new=$(basename "$new" | sed 'y/ğüşıöçĞÜŞİÖÇâîûêôÂÎÛÊÔ/gusiocGUSIOCaiueoAIUEO/')
          new_filename=$(echo "$f" | sed "s/$(basename "$f")/$new/")
          if [[ -d "$new_filename" ]]; then
            cp -R "$f"/* "$new_filename"/
            [[ "$?" == "0" ]] && rm -rf "$f"
            [[ -d "$new_filename" ]] && echo -e "''${YELLOW}Merged contents of \"$f\" to \"$new_filename\"''${NC}"
          elif [[ "$new_filename" != "$f" ]] && [[ ! -f "$new_filename" ]]; then
            mv "$f" "$new_filename"
            [[ -f "$new_filename" ]] && echo -e "''${YELLOW}Renamed \"$f\" to \"$new_filename\"''${NC}"
          fi
        done
        IFS=$OLDIFS
        echo -e "''${GREEN}Renaming process finished.''${NC}"
      '';
      executable = true;
    };
  };
}
