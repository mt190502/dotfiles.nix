## ------------------------------------------------------------------------------------ ##
#  AI Tools Bundle                                                                       #
## ------------------------------------------------------------------------------------ ##
{ pkgs-unstable, ... }:

{
  ########################################
  #
  ## Cursor
  #
  ########################################
  home.packages = with pkgs-unstable; [
    cursor-cli
  ];

  ########################################
  #
  ## OpenCode
  #
  ########################################
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    package = pkgs-unstable.opencode;
    settings = {
      # theme = "flexoki";
      plugin = [
        "opencode-antigravity-auth@latest"
        "@slkiser/opencode-quota"
      ];
      mcp = {
        context7 = {
          type = "remote";
          url = "https://mcp.context7.com/mcp";
        };
        gh_grep = {
          type = "remote";
          url = "https://mcp.grep.app";
        };
        exa = {
          type = "remote";
          url = "https://mcp.exa.ai/mcp";
        };
      };
      permission = {
        bash = "ask";
      };
    };
  };
  home.file.".config/opencode/plugin/terminal-bell.ts".text = ''
    import type { Plugin } from "@opencode-ai/plugin"
    export const TerminalBell: Plugin = async ({ project, client, $, directory, worktree }) => {
      return {
        event: async ({ event }) => {
          if (event.type === "session.idle") {
            await Bun.write(Bun.stdout, "\x07")
          }
        }
      }
    }
  '';
}
