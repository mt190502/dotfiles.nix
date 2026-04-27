{ pkgs, ... }:

with pkgs;
symlinkJoin {
  name = "flameshot";
  paths = [ flameshot ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/flameshot \
      --set QT_STYLE_OVERRIDE kvantum \
      --set XDG_CURRENT_DESKTOP KDE
  '';
  meta.mainProgram = "flameshot";
}
