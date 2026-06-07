## ------------------------------------------------------------------------------------ ##
#  AI Tools Bundle                                                                       #
## ------------------------------------------------------------------------------------ ##
{
  config,
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  ########################################
  #
  ## Packages
  #
  ########################################
  home.packages = [ ];

  ########################################
  #
  ## CommandCode Proxy Server
  #
  ########################################
  systemd.user.services.commandcode-proxy = {
    Unit = {
      Description = "CommandCode Proxy Server";
      After = [ "network.target" ];
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.commandcode-proxy
      }/bin/commandcode-proxy";
      Restart = "always";
      RestartSec = 5;
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

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
      provider = {
        commandcode = {
          name = "CommandCode";
          models = builtins.listToAttrs (
            map
              (model: {
                name = model.id;
                value = {
                  name = model.name;
                  limit = {
                    context = if model.context_length != null then model.context_length else 128000;
                    output = 16384;
                  };
                  modalities = {
                    input = [ "text" ];
                    output = [ "text" ];
                  };
                };
              })
              (builtins.fromJSON (
                builtins.readFile (
                  builtins.fetchurl {
                    url = "http://127.0.0.1:8082/v1/models";
                    sha256 = "0rbkscgin16bj13md5pbwghd6ylkp5mzlwj4rmpwyrc6560kwrx1";
                  }
                )
              )).data
          );
          options = {
            baseURL = "http://127.0.0.1:8082/v1";
            apiKey = "{file:${config.sops.secrets."global/commandcode".path}}";
          };
        };
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
