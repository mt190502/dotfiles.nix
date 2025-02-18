{ ... }:

{
  programs.yt-dlp = {
    enable = true;

    settings = {
      no-mtime = true;
      parse-metadata = "\"playlist_index:%(track_number)s %(release_year|)s:%(meta_date)s track:(?i)(?P<track>.+)s+(?:([^)]*(?:master|edition|original|mix)[^)]*))s* album:(?i)(?P<album>.+)s+(?:([^)]*(?:master|edition)[^)]*))s*\"";
      replace-in-metadata = "'artist' ',.+' ''";
      embed-metadata = true;
      embed-thumbnail = true;
      convert-thumbnails = "jpg";
      ppa = "\"ffmpeg: -c:v mjpeg -vf crop=\\\"'if(gt(ih,iw),iw,ih)':'if(gt(iw,ih),ih,iw)'\\\"\"";
    };
    extraConfig = ''
      -f 251
      -x
      -N 8
    '';
  };
}
