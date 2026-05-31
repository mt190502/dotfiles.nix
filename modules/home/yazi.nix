{
  config,
  lib,
  pkgs,
  ...
}:

let
  term =
    title: command:
    (
      if config.preferences.terminal == "alacritty" then
        lib.getExe pkgs.alacritty + " -T " + title + " -e " + command
      else if config.preferences.terminal == "foot" then
        (lib.getExe' pkgs.foot "footclient") + " -T ${title} ${command}"
      else
        throw "Unsupported terminal: ${config.preferences.terminal}"
    );
in
{
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
    shellWrapperName = "yy";
  };
}
