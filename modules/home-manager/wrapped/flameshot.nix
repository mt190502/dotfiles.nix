{
  config,
  pkgs,
  ...
}:

(pkgs.symlinkJoin {
  name = "flameshot";
  paths = [
    (config.lib.nixGL.wrap pkgs.flameshot)
    # (config.lib.nixGL.wrap (
    #   pkgs.flameshot.overrideAttrs (oldAttrs: {
    #     src = pkgs.fetchFromGitHub {
    #       owner = "flameshot-org";
    #       repo = "flameshot";
    #       rev = "10d12e0";
    #       sha256 = "sha256-3ujqwiQrv/H1HzkpD/Q+hoqyrUdO65gA0kKqtRV0vmw=";
    #     };
    #     cmakeFlags = [
    #       "-DUSE_WAYLAND_CLIPBOARD=1"
    #       "-DUSE_WAYLAND_GRIM=1"
    #     ];
    #     buildInputs = oldAttrs.buildInputs ++ [ pkgs.libsForQt5.kguiaddons ];
    #   })
    # ))
  ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/flameshot \
      --set QT_STYLE_OVERRIDE kvantum \
      --set XDG_CURRENT_DESKTOP KDE
  '';
})
