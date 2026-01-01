{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  cfg = config.moduleopts.home-manager.ai-tools;
in
{
  options.moduleopts.home-manager.ai-tools = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "ai-tools";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs-unstable; [
      cursor-cli
    ];
    programs.opencode = {
      enable = true;
      package = pkgs-unstable.opencode;
      settings = {
        # theme = "flexoki";
        mcp = {
          context7 = {
            type = "remote";
            url = "https://mcp.context7.com/mcp";
          };
        };
        permission = {
          bash = "ask";
        };
      };
    };
  };
}
