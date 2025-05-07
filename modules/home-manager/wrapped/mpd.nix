{ pkgs, ... }:

with pkgs;
rec {
  name = "mpd";
  original = mpd;
  wrap = (
    pkgs.symlinkJoin {
      name = "${name}-wrapped";
      paths = [ original ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/mpd \
          --set ALSA_PLUGIN_DIR ${pkgs.pipewire}/lib/alsa-lib
      '';
    }
  );
}
