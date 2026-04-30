{
  config,
  lib,
  ...
}:

{
  config = lib.mkIf (config.preferences.menu != "vicinae") {
    services.cliphist = {
      enable = true;
      allowImages = true;
      systemdTargets = [
        "${config.preferences.desktopenv}-session.target"
      ];
    };
  };
}
