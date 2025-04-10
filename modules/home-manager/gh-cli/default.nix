{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.gh-cli;
in
{
  options.moduleopts.gh-cli = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "GitHub CLI";
    };
  };
  config = lib.mkIf cfg.enable {
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
  };
}
