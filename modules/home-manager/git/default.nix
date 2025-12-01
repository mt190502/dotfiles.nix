{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager;
in
{
  options.moduleopts.home-manager.git = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "git";
    };
  };
  config = lib.mkIf cfg.git.enable {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "Taha";
          email = "mt190502@mtaha.dev";
        };
        signing = {
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKVyQNBWyCGvlRlqEh/3Ga6CDF01MZo6Jj15mjqHzPFD";
          format = "ssh";
        };
      };
    };
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        color.ui = "auto";
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
      };
    };
  };
}
