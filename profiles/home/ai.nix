## ------------------------------------------------------------------------------------ ##
#  AI Tools Bundle                                                                       #
## ------------------------------------------------------------------------------------ ##
{
  config,
  inputs,
  lib,
  osConfig ? null,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  commandcode-proxy-bin = "${
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.commandcode-proxy
  }/bin/commandcode-proxy";
in

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
  systemd.user.services.commandcode-proxy = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
    Unit = {
      Description = "CommandCode Proxy Server";
      After = [ "network.target" ];
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = commandcode-proxy-bin;
      Restart = "always";
      RestartSec = 5;
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  launchd.agents.commandcode-proxy =
    lib.mkIf (osConfig != null && pkgs.stdenv.hostPlatform.isDarwin)
      {
        enable = true;
        config = {
          ProgramArguments = [ commandcode-proxy-bin ];
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/commandcode-proxy.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/commandcode-proxy.log";
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
          models = {
            "MiniMaxAI/MiniMax-M2.7" = {
              limit = {
                context = 200000;
                output = 16384;
              };
              modalities = {
                input = [
                  "text"
                ];
                output = [
                  "text"
                ];
              };
              name = "MiniMax M2.7";
            };
            "Qwen/Qwen3.7-Max" = {
              limit = {
                context = 1000000;
                output = 16384;
              };
              modalities = {
                input = [
                  "text"
                ];
                output = [
                  "text"
                ];
              };
              name = "Qwen 3.7 Max";
            };
            "Qwen/Qwen3.7-Plus" = {
              limit = {
                context = 1000000;
                output = 16384;
              };
              modalities = {
                input = [
                  "text"
                ];
                output = [
                  "text"
                ];
              };
              name = "Qwen 3.7 Plus";
            };
            "deepseek/deepseek-v4-flash" = {
              limit = {
                context = 1000000;
                output = 16384;
              };
              modalities = {
                input = [
                  "text"
                ];
                output = [
                  "text"
                ];
              };
              name = "DeepSeek V4 Flash";
            };
            "deepseek/deepseek-v4-pro" = {
              limit = {
                context = 1000000;
                output = 16384;
              };
              modalities = {
                input = [
                  "text"
                ];
                output = [
                  "text"
                ];
              };
              name = "DeepSeek V4 Pro";
            };
            "gpt-5.3-codex" = {
              limit = {
                context = 400000;
                output = 16384;
              };
              modalities = {
                input = [
                  "text"
                ];
                output = [
                  "text"
                ];
              };
              name = "GPT-5.3 Codex";
            };
            "gpt-5.4" = {
              limit = {
                context = 400000;
                output = 16384;
              };
              modalities = {
                input = [
                  "text"
                ];
                output = [
                  "text"
                ];
              };
              name = "GPT-5.4";
            };
            "gpt-5.4-mini" = {
              limit = {
                context = 400000;
                output = 16384;
              };
              modalities = {
                input = [
                  "text"
                ];
                output = [
                  "text"
                ];
              };
              name = "GPT-5.4 Mini";
            };
            "gpt-5.5" = {
              limit = {
                context = 200000;
                output = 16384;
              };
              modalities = {
                input = [
                  "text"
                ];
                output = [
                  "text"
                ];
              };
              name = "GPT-5.5";
            };
            "moonshotai/Kimi-K2.6" = {
              limit = {
                context = 256000;
                output = 16384;
              };
              modalities = {
                input = [
                  "text"
                ];
                output = [
                  "text"
                ];
              };
              name = "Kimi K2.6";
            };
            "nvidia/nemotron-3-ultra-550b-a55b" = {
              limit = {
                context = 1000000;
                output = 16384;
              };
              modalities = {
                input = [
                  "text"
                ];
                output = [
                  "text"
                ];
              };
              name = "Nemotron 3 Ultra";
            };
            "stepfun/Step-3.5-Flash" = {
              limit = {
                context = 1000000;
                output = 16384;
              };
              modalities = {
                input = [
                  "text"
                ];
                output = [
                  "text"
                ];
              };
              name = "Step 3.5 Flash";
            };
            "stepfun/Step-3.7-Flash" = {
              limit = {
                context = 256000;
                output = 16384;
              };
              modalities = {
                input = [
                  "text"
                ];
                output = [
                  "text"
                ];
              };
              name = "Step 3.7 Flash";
            };
            "xiaomi/mimo-v2.5" = {
              limit = {
                context = 1000000;
                output = 16384;
              };
              modalities = {
                input = [
                  "text"
                ];
                output = [
                  "text"
                ];
              };
              name = "MiMo V2.5";
            };
            "xiaomi/mimo-v2.5-pro" = {
              limit = {
                context = 1000000;
                output = 16384;
              };
              modalities = {
                input = [
                  "text"
                ];
                output = [
                  "text"
                ];
              };
              name = "MiMo V2.5 Pro";
            };
            "zai-org/GLM-5" = {
              limit = {
                context = 200000;
                output = 16384;
              };
              modalities = {
                input = [
                  "text"
                ];
                output = [
                  "text"
                ];
              };
              name = "GLM-5";
            };
            "zai-org/GLM-5.1" = {
              limit = {
                context = 200000;
                output = 16384;
              };
              modalities = {
                input = [
                  "text"
                ];
                output = [
                  "text"
                ];
              };
              name = "GLM-5.1";
            };
          };
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
