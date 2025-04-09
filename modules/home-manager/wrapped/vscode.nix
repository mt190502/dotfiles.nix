{
  config,
  pkgs,
  ...
}:

(config.lib.nixGL.wrap (
  pkgs.symlinkJoin {
    name = "vscode";
    paths = [ pkgs.vscode ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/code \
        --set XDG_CURRENT_DESKTOP GNOME \
        --append-flags "--ozone-platform=wayland --ozone-platform-hint=auto --password-store=gnome"
    '';
  }
))
