{
  lib,
  symlinkJoin,
  kdePackages,
  makeWrapper,
  ...
}:

symlinkJoin {
  name = "okular";
  paths = [ kdePackages.okular ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/okular \
      --set QT_QPA_PLATFORMTHEME qt6ct \
      --set QT_STYLE_OVERRIDE kvantum \
      --run 'rc="$HOME/.config/okularrc"; touch "$rc"; if grep -q "^\[UiSettings\]" "$rc"; then sed -i "/^\[UiSettings\]/,/^\[/{s/^ColorScheme=.*/ColorScheme=BreezeDark/}" "$rc"; grep -A1 "^\[UiSettings\]" "$rc" | grep -q "^ColorScheme=" || sed -i "/^\[UiSettings\]/a ColorScheme=BreezeDark" "$rc"; else printf "\n[UiSettings]\nColorScheme=BreezeDark\n" >> "$rc"; fi'
  '';
  meta = {
    mainProgram = "okular";
    platforms = lib.platforms.linux;
  };
}
