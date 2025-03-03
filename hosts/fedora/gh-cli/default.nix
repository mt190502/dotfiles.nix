{ pkgs, ... }:

{
  programs.gh = {
    enable = true;

    extensions = with pkgs; [
      gh-copilot
    ];

    settings = {
      editor = "vim";
      git_protocol = "ssh";
    };
  };
}