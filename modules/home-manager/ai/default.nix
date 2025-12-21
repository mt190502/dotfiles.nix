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
  config = lib.mkIf cfg.enable (
    with pkgs-unstable;
    {
      home.packages = [
        cursor-cli
      ];
      programs.gemini-cli = {
        enable = true;
        package = gemini-cli;
        defaultModel = "gemini-2.5-pro";
        settings = {
          general = {
            vimMode = true;
          };
          security = {
            auth = {
              selectedType = "oauth-personal";
            };
          };
        };
      };
      programs.opencode = {
        enable = true;
        package = opencode;
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
    }
  );
}
