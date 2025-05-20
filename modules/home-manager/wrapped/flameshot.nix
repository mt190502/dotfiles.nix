{ config, pkgs, ... }:

let
  originalPackage = pkgs.flameshot;
  # pkgs.flameshot.overrideAttrs (oldAttrs: {
  #   src = fetchFromGitHub {
  #     owner = "flameshot-org";
  #     repo = "flameshot";
  #     rev = "f4cde19";
  #     sha256 = "sha256-B/piB8hcZR11vnzvue/1eR+SFviTSGJoek1w4abqsek=";
  #   };
  #   cmakeFlags = [
  #     "-DUSE_WAYLAND_CLIPBOARD=1"
  #     "-DUSE_WAYLAND_GRIM=1"
  #   ];
  #   buildInputs = oldAttrs.buildInputs ++ [ libsForQt5.kguiaddons ];
  # })
  override = pkgs.symlinkJoin {
    name = "flameshot-wrapped";
    paths = [ originalPackage ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/flameshot \
        --set QT_STYLE_OVERRIDE kvantum \
        --set XDG_CURRENT_DESKTOP KDE
    '';
    meta.mainProgram = "flameshot";
  };
in
{
  name = "flameshot";
  original = originalPackage;
  wrap =
    if config.wrapped.mode == "nixGL" then
      config.lib.nixGL.wrap override
    else if config.wrapped.mode == "standard" then
      override
    else
      throw "Invalid mode for vscode: ${config.wrapped.mode}. Valid modes are: nixGL, standard.";
}
