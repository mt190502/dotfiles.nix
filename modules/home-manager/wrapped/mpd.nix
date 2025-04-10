{
  pkgs,
  ...
}:

(pkgs.symlinkJoin {
  name = "mpd";
  paths = [ pkgs.mpd ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/mpd \
      --set ALSA_PLUGIN_DIR ${pkgs.pipewire}/lib/alsa-lib
  '';
})
