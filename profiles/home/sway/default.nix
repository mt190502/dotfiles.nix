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
  inherit (lib) getExe;

  player =
    if config.preferences.mediaplayer == "ncmpcpp" then
      getExe pkgs.ncmpcpp
    else if config.preferences.mediaplayer == "rmpc" then
      getExe pkgs.rmpc
    else
      throw "No preferred music player selected";
in
{
  imports = [
    inputs.self.homeModules.theming
    inputs.self.homeModules.mtshell
    ./mtshell/bar.nix
    ./mtshell/notifier.nix
    # ./cliphist.nix
    ./kde-apps-wm-fix.nix
    # ./mako.nix
    ./qt-apps-wm-fix.nix
    ./swappy.nix
    ./sway.nix
    ./swaylock.nix
    ./swaynag.nix
    ./swaync.nix
    # ./waybar.nix
    # ./wofi.nix
    ./xdg-portal.nix
  ];
  config = {
    preferences = {
      desktopenv = lib.mkDefault "sway";
      lock-app = lib.mkDefault "swaylock";
      notifier = lib.mkDefault "swaync";
    };
    xdg.configFile = builtins.listToAttrs (
      lib.map (
        path:
        let
          filePath = ./scripts.d + "/${path}";
          subs = mkSubstitutions {
            files = [ filePath ];
            custom = {
              inherit player;
              preferred_terminal = config.preferences.terminal;
            };
          };
        in
        {
          name = "sway/scripts.d/${path}";
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
        }
      ) (builtins.attrNames (builtins.readDir ./scripts.d))
    );
  };
}
