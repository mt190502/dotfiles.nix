{
  pkgs,
  ...
}:

(pkgs.symlinkJoin {
  name = "waybar";
  paths = [ pkgs.waybar ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/waybar \
      --set GTK_THEME Adwaita:dark
  '';
})
