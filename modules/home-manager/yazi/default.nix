{
  config,
  lib,
  pkgs,
  system,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
  term =
    title: command:
    (
      if cfg.preferred.terminal == "alacritty" then
        lib.getExe pkgs.alacritty + " -T " + title + " -e " + command
      else if cfg.preferred.terminal == "foot" then
        (lib.getExe' pkgs.foot "footclient") + " -T ${title} ${command}"
      else
        throw "Unsupported terminal: ${cfg.preferred.terminal}"
    );
in
{
  options.moduleopts.home-manager.yazi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Yazi configuration for Home Manager.";
    };
  };
  config = lib.mkIf (cfg.yazi.enable && lib.hasSuffix "linux" system) {
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
      keymap = {
        mgr.prepend_keymap = [
          {
            on = "<C-f>";
            run = "fzf";
          }
          {
            on = "<C-n>";
            run = ''shell '${lib.getExe pkgs.dragon-drop} -x -i -T "$@" 2>/dev/null &' --confirm'';
          }
          {
            on = "t";
            run = "shell '${term "yazi" "fish"}' --confirm";
          }
          {
            on = [ "u" ];
            run = "plugin restore";
          }
          {
            on = [
              "y"
              "y"
            ];
            run = "plugin wl-clipboard";
          }
        ];
      };
      plugins = {
        inherit (pkgs.yaziPlugins) mount restore wl-clipboard;
      };
    };
  };
}
