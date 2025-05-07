{ config, pkgs, ... }:

with pkgs;
rec {
  name = "code-cursor";
  original = code-cursor;
  wrap = (
    config.lib.nixGL.wrap (symlinkJoin {
      name = "${name}-wrapped";
      paths = [ original ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/cursor \
          --set XDG_CURRENT_DESKTOP GNOME \
          --append-flags "--ozone-platform=wayland --ozone-platform-hint=auto --password-store=gnome"
      '';
    })
  );
}
