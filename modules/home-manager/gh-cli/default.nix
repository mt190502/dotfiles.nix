{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager.gh-cli;
in
{
  options.moduleopts.home-manager.gh-cli = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "gh-cli";
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
