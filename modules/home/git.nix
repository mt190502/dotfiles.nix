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
    settings = {
      commit.gpgsign = true;
      gpg = {
        format = "ssh";
        "ssh".program = lib.mkIf (osConfig != null) (
          lib.getExe' osConfig.programs._1password-gui.package "op-ssh-sign"
        );
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
