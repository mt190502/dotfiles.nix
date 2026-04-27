{ config, pkgs, ... }:

{
  programs.git.enable = true;
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
