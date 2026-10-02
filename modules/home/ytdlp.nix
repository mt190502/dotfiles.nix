{
  config,
  lib,
  pkgs,
  ...
}:

let
  home = config.home.homeDirectory;
  bash = lib.getExe pkgs.bash;
in
{
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
      #!${bash}
      set -u

      ROOT='${home}/Music/Artists'
      YELLOW='\033[1;33m'
      RED='\033[0;31m'
      NC='\033[0m'

      normalize_component() {
        local value="$1"
        value=$(printf '%s' "$value" \
          | sed -e 's/，/,/g; s/：/:/g; s/＂/"/g; s/（/(/g; s/）/)/g; s/；/;/g; s/＆/\&/g; s/⧸/-/g' \
          | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null \
          | sed -e 's/&/feat./g' -e 's#[\/:*?"<>|]#-#g' \
                -e 's/[[:cntrl:]]//g' -e 's/[[:space:]][[:space:]]*/ /g' \
                -e 's/^[ .-]*//; s/[ .-]*$//')
        printf '%s' "$value"
      }

      same_file() {
        [[ -f "$1" && -f "$2" ]] && cmp -s -- "$1" "$2"
      }

      move_file() {
        local source="$1" target="$2"
        [[ "$source" == "$target" ]] && return 0
        mkdir -p -- "$(dirname -- "$target")"
        if [[ -e "$target" || -L "$target" ]]; then
          if same_file "$source" "$target"; then
            rm -f -- "$source"
            printf '%bRemoved identical duplicate: %s%b\n' "$YELLOW" "$source" "$NC"
            return 0
          fi
          printf '%bCollision, kept source: %s -> %s%b\n' "$RED" "$source" "$target" "$NC" >&2
          return 1
        fi
        mv -- "$source" "$target"
        printf '%bRenamed: %s -> %s%b\n' "$YELLOW" "$source" "$target" "$NC"
      }

      [[ $# -ge 1 ]] || exit 0
      file="$1"
      [[ -e "$file" || -L "$file" ]] || exit 0
      case "$file" in
        "$ROOT"/*) ;;
        *) exit 0 ;;
      esac

      parent=$(dirname -- "$file")
      name=$(basename -- "$file")
      normalized=$(normalize_component "$name")
      if [[ "$normalized" != "$name" ]]; then
        target="$parent/$normalized"
        move_file "$file" "$target" || exit 0
        file="$target"
      fi

      parent=$(dirname -- "$file")
      while [[ "$parent" != "$ROOT" && "$parent" == "$ROOT"/* ]]; do
        name=$(basename -- "$parent")
        normalized=$(normalize_component "$name")
        grandparent=$(dirname -- "$parent")
        if [[ "$normalized" == "$name" ]]; then
          parent="$grandparent"
          continue
        fi

        target_dir="$grandparent/$normalized"
        target_file="$target_dir/$(basename -- "$file")"
        if [[ -d "$target_dir" ]]; then
          move_file "$file" "$target_file" || exit 0
          rmdir -- "$parent" 2>/dev/null || true
          file="$target_file"
        elif [[ ! -e "$target_dir" && ! -L "$target_dir" ]]; then
          mv -- "$parent" "$target_dir"
          printf '%bRenamed directory: %s -> %s%b\n' "$YELLOW" "$parent" "$target_dir" "$NC"
          file="$target_file"
        else
          printf '%bCollision, kept directory: %s -> %s%b\n' "$RED" "$parent" "$target_dir" "$NC" >&2
          exit 0
        fi
        parent=$(dirname -- "$file")
      done
    '';
    executable = true;
  };
}
