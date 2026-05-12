{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

{
  programs.git = {
    enable = true;
    settings.gpg."ssh".program = lib.mkIf (osConfig != null) (
      lib.getExe' osConfig.programs._1password-gui.package "op-ssh-sign"
    );
  };
  programs.gh = {
    enable = true;
    extensions = with pkgs; [
      gh-copilot
    ];
    settings = {
      editor = config.home.sessionVariables.EDITOR or "vim";
      git_protocol = "ssh";
    };
  };
}
