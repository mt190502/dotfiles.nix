{
  config,
  inputs,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  inherit (import "${inputs.self}/lib/substitutions.nix" { inherit lib pkgs pkgs-unstable; })
    mkSubstitutions
    ;
  inherit (lib) getExe';

  guiScripts = [
    "easy-tesseract"
    "mako-dnd-toggle"
    "powermenu"
    "wofimoji"
    "xdg-screen-cast"
  ];

  allScripts = builtins.readDir ./scripts.d;
  activeScripts = removeAttrs allScripts (
    lib.optionals (!(config.preferences.desktopenv != "none")) guiScripts
  );

  mkScript =
    path:
    let
      filePath = ./scripts.d + "/${path}";
      subs = mkSubstitutions {
        files = [ filePath ];
        custom = {
          lock-screen-function = "${getExe' pkgs.systemd "systemctl"} --user start session-lock";
        };
      };
    in
    {
      name = ".local/bin/${path}";
      value = {
        executable = true;
        source = pkgs.substitute {
          src = filePath;
          substitutions = lib.flatten (
            lib.mapAttrsToList (k: v: [
              "--replace"
              "@${k}@"
              "${v}"
            ]) subs
          );
        };
      };
    };
in
{
  config = lib.mkIf (lib.hasSuffix "linux" pkgs.stdenv.hostPlatform.system) {
    home.file = builtins.listToAttrs (map mkScript (builtins.attrNames activeScripts));
  };
}
