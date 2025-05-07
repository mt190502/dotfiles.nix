{
  config,
  pkgs,
  ...
}:

with pkgs;
rec {
  name = "flameshot";
  original = flameshot;
  wrap = (
    symlinkJoin {
      name = "${name}-wrapped";
      paths = [
        (config.lib.nixGL.wrap original)
        # (config.lib.nixGL.wrap (
        #   flameshot.overrideAttrs (oldAttrs: {
        #     src = fetchFromGitHub {
        #       owner = "flameshot-org";
        #       repo = "flameshot";
        #       rev = "f4cde19";
        #       sha256 = "sha256-B/piB8hcZR11vnzvue/1eR+SFviTSGJoek1w4abqsek=";
        #     };
        #     cmakeFlags = [
        #       "-DUSE_WAYLAND_CLIPBOARD=1"
        #       "-DUSE_WAYLAND_GRIM=1"
        #     ];
        #     buildInputs = oldAttrs.buildInputs ++ [ libsForQt5.kguiaddons ];
        #   })
        # ))
      ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/flameshot \
          --set QT_STYLE_OVERRIDE kvantum \
          --set XDG_CURRENT_DESKTOP KDE
      '';
      meta.mainProgram = "flameshot";
    }
  );
}
