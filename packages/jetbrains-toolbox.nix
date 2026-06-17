{
  symlinkJoin,
  pkgs-unstable,
  makeWrapper,
  ...
}:

symlinkJoin {
  name = "jetbrains-toolbox";
  paths = [ pkgs-unstable.jetbrains-toolbox ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/jetbrains-toolbox \
      --set XDG_CURRENT_DESKTOP GNOME \
      --set GNOME_DESKTOP_SESSION_ID this-is-deprecated
  '';
  meta.mainProgram = "jetbrains-toolbox";
}
