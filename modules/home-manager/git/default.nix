{
  config,
  lib,
  ...
}:

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
      userName = "Taha";
      userEmail = "mt190502@mtaha.dev";
      signing = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKVyQNBWyCGvlRlqEh/3Ga6CDF01MZo6Jj15mjqHzPFD";
        format = "ssh";
      };
      delta = {
        enable = true;
        options = {
          navigate = true;
        };
      };
      extraConfig = {
        color.ui = "auto";
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
      };
    };
  };
}
