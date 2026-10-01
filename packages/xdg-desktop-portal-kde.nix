{
  lib,
  symlinkJoin,
  kdePackages,
  makeWrapper,
  ...
}:

let
  base = kdePackages.xdg-desktop-portal-kde;
in
symlinkJoin {
  name = "xdg-desktop-portal-kde";
  paths = [ base ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/libexec/xdg-desktop-portal-kde \
      --set QT_QPA_PLATFORMTHEME kde \
      --prefix QT_PLUGIN_PATH : ${kdePackages.plasma-integration}/lib/qt-6/plugins \
      --unset PLASMA_INTEGRATION_USE_PORTAL \
      --add-flags "-style kvantum-dark"
    for f in $out/share/dbus-1/services/*.service $out/share/systemd/user/*.service; do
      if [ -f "$f" ]; then
        sed -i "s|${base}/libexec/xdg-desktop-portal-kde|$out/libexec/xdg-desktop-portal-kde|g" "$f"
      fi
    done
  '';
  meta = {
    mainProgram = "xdg-desktop-portal-kde";
    platforms = lib.platforms.linux;
  };
}
