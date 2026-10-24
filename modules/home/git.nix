{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  op = osConfig != null && (osConfig.programs._1password-gui.enable or false);
in
{
  programs.git = {
    enable = true;
    settings = {
      commit.gpgsign = lib.mkDefault op;
      gpg = {
        format = "ssh";
        "ssh".program = lib.mkIf op (lib.getExe' osConfig.programs._1password-gui.package "op-ssh-sign");
      };
    };
  };
  programs.gh = {
    enable = true;
    extensions = with pkgs; [
      github-copilot-cli
    ];
    settings = {
      editor = config.home.sessionVariables.EDITOR or "vim";
      git_protocol = "ssh";
    };
  };
}
